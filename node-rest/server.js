/**
 * Node.js REST API Server
 * 
 * Proyecto: Sistema de Billetera Digital ePayco
 * Descripción: Servidor REST API que expone endpoints HTTP para operaciones de billetera digital.
 *              Este servidor actúa como interfaz REST y se comunica con el servicio SOAP de Laravel
 *              para realizar todas las operaciones. No tiene acceso directo a la base de datos.
 * 
 * Empresa: ePayco
 * @Autor: Juan Hernandez
 */
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const soap = require('soap');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const SOAP_URL = process.env.SOAP_URL || 'http://localhost:8000/soap/wsdl';

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

app.use(limiter);

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Cookie parser with security
app.use(cookieParser());

// Secure cookie configuration
app.use((req, res, next) => {
  res.cookie('session', '', {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 3600000
  });
  next();
});

// Helper function to create SOAP client
function createSoapClient() {
  return new Promise((resolve, reject) => {
    console.log('Creating SOAP client with URL:', SOAP_URL);
    soap.createClient(SOAP_URL, {
      wsdl_options: {
        timeout: 10000,
        connection_timeout: 10000
      },
      // Force SOAP 1.2
      forceSoap12Headers: true,
      // Enable XML escaping
      escapeXML: true,
      // Disable namespace array elements
      namespaceArrayElements: false,
      // Enable request/response logging
      returnFault: true
    }, (err, client) => {
      if (err) {
        console.error('SOAP Client Error:', err);
        console.error('Error details:', JSON.stringify(err, null, 2));
        reject(err);
      } else {
        console.log('SOAP Client created successfully');
        console.log('Available methods:', Object.keys(client));
        
        // Enable request/response logging
        client.on('request', function(xml, eid) {
          console.log('SOAP Request XML:', xml);
        });
        
        client.on('response', function(xml, eid) {
          console.log('SOAP Response XML:', xml);
        });
        
        resolve(client);
      }
    });
  });
}

// Standard response structure
function buildResponse(success, codError, messageError, data) {
  return {
    success: success,
    cod_error: codError,
    message_error: messageError,
    data: data
  };
}

// Input sanitization - trim whitespace only
// XML escaping is handled automatically by the SOAP library
function sanitizeInput(input) {
  if (typeof input !== 'string') return input;
  return input.trim();
}

// Validation error handler
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json(
      buildResponse(false, '01', 'Error de validación', errors.array())
    );
  }
  next();
}

// POST /api/register-client
app.post('/api/register-client', [
  body('document').notEmpty().withMessage('Documento es requerido').trim().escape(),
  body('fullName').notEmpty().withMessage('Nombres son requeridos').trim().escape(),
  body('email').isEmail().withMessage('Email válido es requerido').normalizeEmail(),
  body('phoneNumber').notEmpty().withMessage('Celular es requerido').trim().escape(),
  handleValidationErrors
], async (req, res) => {
  try {
    const { document, fullName, email, phoneNumber } = req.body;
    
    const client = await createSoapClient();
    
    // Verificar que el método existe
    if (!client.registerClient) {
      console.error('Method registerClient not found in SOAP client');
      return res.status(500).json(
        buildResponse(false, '99', 'Método SOAP no encontrado', null)
      );
    }
    
    // Log the request data before sending
    const requestData = {
      document: sanitizeInput(document),
      fullName: sanitizeInput(fullName),
      email: sanitizeInput(email),
      phoneNumber: sanitizeInput(phoneNumber)
    };
    console.log('Sending SOAP request data:', JSON.stringify(requestData, null, 2));
    
    client.registerClient(requestData, (err, result, rawResponse, soapHeader, rawRequest) => {
      // Log the raw request XML if available
      if (rawRequest) {
        console.log('Raw SOAP Request XML:', rawRequest);
      }
      if (client.lastRequest) {
        console.log('Last SOAP Request XML:', client.lastRequest);
      }
      if (err) {
        console.error('SOAP Call Error:', err);
        console.error('Error type:', typeof err);
        console.error('Error keys:', Object.keys(err || {}));
        
        // Extract error message from various error structures
        let errorMsg = 'Error desconocido';
        
        if (err.Fault) {
          errorMsg = err.Fault.faultstring || err.Fault.detail || 'Error SOAP';
          console.error('SOAP Fault:', err.Fault);
        } else if (err.response && err.response.data) {
          // Handle HTML error responses (like PHP errors)
          const htmlData = typeof err.response.data === 'string' ? err.response.data : '';
          // Try to extract PHP error message from HTML
          const phpErrorMatch = htmlData.match(/Error: ([^\n]+)/);
          if (phpErrorMatch) {
            errorMsg = `Error del servidor: ${phpErrorMatch[1]}`;
          } else {
            errorMsg = 'Error del servidor SOAP';
          }
        } else if (err.body) {
          const htmlBody = typeof err.body === 'string' ? err.body : '';
          const phpErrorMatch = htmlBody.match(/Error: ([^\n]+)/);
          if (phpErrorMatch) {
            errorMsg = `Error del servidor: ${phpErrorMatch[1]}`;
          } else {
            errorMsg = err.body.substring(0, 200);
          }
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + errorMsg, null)
        );
      }
      
      const response = result?.return || result?.registerClientResponse || result || {};
      console.log('SOAP Response:', JSON.stringify(result, null, 2));
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    console.error('Catch Error:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + (error.message || String(error)), null)
    );
  }
});

// POST /api/recharge-wallet
app.post('/api/recharge-wallet', [
  body('document').notEmpty().withMessage('Documento es requerido').trim().escape(),
  body('phoneNumber').notEmpty().withMessage('Celular es requerido').trim().escape(),
  body('amount').isFloat({ min: 0.01 }).withMessage('Monto válido es requerido'),
  handleValidationErrors
], async (req, res) => {
  try {
    const { document, phoneNumber, amount } = req.body;
    
    const client = await createSoapClient();
    
    client.rechargeWallet({
      document: sanitizeInput(document),
      phoneNumber: sanitizeInput(phoneNumber),
      amount: parseFloat(amount)
    }, (err, result) => {
      if (err) {
        console.error('SOAP Call Error:', err);
        let errorMsg = 'Error desconocido';
        
        if (err.Fault) {
          errorMsg = err.Fault.faultstring || err.Fault.detail || 'Error SOAP';
        } else if (err.response?.data) {
          const htmlData = typeof err.response.data === 'string' ? err.response.data : '';
          const phpErrorMatch = htmlData.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : 'Error del servidor SOAP';
        } else if (err.body) {
          const htmlBody = typeof err.body === 'string' ? err.body : '';
          const phpErrorMatch = htmlBody.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : err.body.substring(0, 200);
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + errorMsg, null)
        );
      }
      
      const response = result.return || result.rechargeWalletResponse || result;
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + error.message, null)
    );
  }
});

// POST /api/initiate-payment
app.post('/api/initiate-payment', [
  body('document').notEmpty().withMessage('Documento es requerido').trim().escape(),
  body('phoneNumber').notEmpty().withMessage('Celular es requerido').trim().escape(),
  body('amount').isFloat({ min: 0.01 }).withMessage('Monto válido es requerido'),
  handleValidationErrors
], async (req, res) => {
  try {
    const { document, phoneNumber, amount } = req.body;
    
    const client = await createSoapClient();
    
    client.initiatePayment({
      document: sanitizeInput(document),
      phoneNumber: sanitizeInput(phoneNumber),
      amount: parseFloat(amount)
    }, (err, result) => {
      if (err) {
        console.error('SOAP Call Error:', err);
        let errorMsg = 'Error desconocido';
        
        if (err.Fault) {
          errorMsg = err.Fault.faultstring || err.Fault.detail || 'Error SOAP';
        } else if (err.response?.data) {
          const htmlData = typeof err.response.data === 'string' ? err.response.data : '';
          const phpErrorMatch = htmlData.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : 'Error del servidor SOAP';
        } else if (err.body) {
          const htmlBody = typeof err.body === 'string' ? err.body : '';
          const phpErrorMatch = htmlBody.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : err.body.substring(0, 200);
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + errorMsg, null)
        );
      }
      
      const response = result.return || result.initiatePaymentResponse || result;
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + error.message, null)
    );
  }
});

// POST /api/confirm-payment
app.post('/api/confirm-payment', [
  body('sessionId').notEmpty().withMessage('ID de sesión es requerido').trim().escape(),
  body('token').isLength({ min: 6, max: 6 }).withMessage('Token de 6 dígitos es requerido').trim().escape(),
  handleValidationErrors
], async (req, res) => {
  try {
    const { sessionId, token } = req.body;
    
    const client = await createSoapClient();
    
    client.confirmPayment({
      sessionId: sanitizeInput(sessionId),
      token: sanitizeInput(token)
    }, (err, result) => {
      if (err) {
        console.error('SOAP Call Error:', err);
        let errorMsg = 'Error desconocido';
        
        if (err.Fault) {
          errorMsg = err.Fault.faultstring || err.Fault.detail || 'Error SOAP';
        } else if (err.response?.data) {
          const htmlData = typeof err.response.data === 'string' ? err.response.data : '';
          const phpErrorMatch = htmlData.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : 'Error del servidor SOAP';
        } else if (err.body) {
          const htmlBody = typeof err.body === 'string' ? err.body : '';
          const phpErrorMatch = htmlBody.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : err.body.substring(0, 200);
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + errorMsg, null)
        );
      }
      
      const response = result.return || result.confirmPaymentResponse || result;
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + error.message, null)
    );
  }
});

// POST /api/check-balance
app.post('/api/check-balance', [
  body('document').notEmpty().withMessage('Documento es requerido').trim().escape(),
  body('phoneNumber').notEmpty().withMessage('Celular es requerido').trim().escape(),
  handleValidationErrors
], async (req, res) => {
  try {
    const { document, phoneNumber } = req.body;
    
    const client = await createSoapClient();
    
    client.checkBalance({
      document: sanitizeInput(document),
      phoneNumber: sanitizeInput(phoneNumber)
    }, (err, result) => {
      if (err) {
        console.error('SOAP Call Error:', err);
        let errorMsg = 'Error desconocido';
        
        if (err.Fault) {
          errorMsg = err.Fault.faultstring || err.Fault.detail || 'Error SOAP';
        } else if (err.response?.data) {
          const htmlData = typeof err.response.data === 'string' ? err.response.data : '';
          const phpErrorMatch = htmlData.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : 'Error del servidor SOAP';
        } else if (err.body) {
          const htmlBody = typeof err.body === 'string' ? err.body : '';
          const phpErrorMatch = htmlBody.match(/Error: ([^\n]+)/);
          errorMsg = phpErrorMatch ? `Error del servidor: ${phpErrorMatch[1]}` : err.body.substring(0, 200);
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + errorMsg, null)
        );
      }
      
      const response = result.return || result.checkBalanceResponse || result;
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + error.message, null)
    );
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'REST Wallet Service' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json(
    buildResponse(false, '99', 'Error interno del servidor', null)
  );
});

// 404 handler
app.use((req, res) => {
  res.status(404).json(
    buildResponse(false, '404', 'Endpoint no encontrado', null)
  );
});

app.listen(PORT, () => {
  console.log(`REST Service running on port ${PORT}`);
  console.log(`SOAP Service URL: ${SOAP_URL}`);
});

