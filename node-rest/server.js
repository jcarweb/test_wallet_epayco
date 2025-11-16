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
    soap.createClient(SOAP_URL, (err, client) => {
      if (err) {
        reject(err);
      } else {
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

// Input sanitization
function sanitizeInput(input) {
  if (typeof input !== 'string') return input;
  return input.trim()
    .replace(/[<>]/g, '')
    .replace(/['"]/g, '');
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
    
    client.registerClient({
      document: sanitizeInput(document),
      fullName: sanitizeInput(fullName),
      email: sanitizeInput(email),
      phoneNumber: sanitizeInput(phoneNumber)
    }, (err, result) => {
      if (err) {
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + err.message, null)
        );
      }
      
      const response = result.return || result.registerClientResponse || result;
      res.status(response.success ? 200 : 400).json(response);
    });
  } catch (error) {
    res.status(500).json(
      buildResponse(false, '99', 'Error interno del servidor: ' + error.message, null)
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
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + err.message, null)
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
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + err.message, null)
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
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + err.message, null)
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
        return res.status(500).json(
          buildResponse(false, '99', 'Error al comunicarse con el servicio SOAP: ' + err.message, null)
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

