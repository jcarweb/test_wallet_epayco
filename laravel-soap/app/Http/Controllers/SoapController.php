<?php
/**
 * Controlador SOAP para manejar solicitudes y respuestas SOAP en Laravel.
 * 
 * Proyecto: Sistema de Billetera Digital ePayco
 * Descripción: Servicio SOAP que gestiona operaciones de billetera digital incluyendo
 *              registro de clientes, recarga de saldo, iniciación y confirmación de pagos,
 *              y consulta de saldo. Este servicio actúa como capa de acceso exclusiva
 *              a la base de datos del sistema.
 * 
 * Empresa: ePayco
 * @Autor: Juan Hernandez
 */
namespace App\Http\Controllers;

use App\Services\WalletSoapService;
use Illuminate\Http\Request;

class SoapController extends Controller
{
    protected $walletService;

    public function __construct(WalletSoapService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function wsdl()
    {
        $wsdl = view('soap.wsdl')->render();
        return response($wsdl, 200)->header('Content-Type', 'text/xml; charset=utf-8');
    }

    public function service(Request $request)
    {
        try {
            // Verificar si la extensión SOAP está cargada
            if (!extension_loaded('soap')) {
                \Log::error('Extensión SOAP no cargada', [
                    'loaded_extensions' => get_loaded_extensions(),
                    'php_version' => PHP_VERSION,
                    'sapi' => php_sapi_name()
                ]);
                throw new \Exception('La extensión SOAP no está cargada. Por favor, habilite la extensión SOAP en PHP.');
            }
            
            \Log::info('Extensión SOAP verificada correctamente');
            
            // Usar el valor de la constante directamente para evitar problemas de namespace
            // El valor de la constante SOAP_1_2 es 2
            $soapVersion = 2;
            
            // Obtener el contenido del WSDL directamente en lugar de usar URL
            // Esto evita problemas con puertos y acceso HTTP
            $wsdlContent = view('soap.wsdl')->render();
            
            // Obtener el puerto de la solicitud actual para las opciones
            $port = $request->getPort();
            $host = $request->getHost();
            $scheme = $request->getScheme();
            
            $baseUrl = $scheme . '://' . $host . ($port && $port != 80 && $port != 443 ? ':' . $port : '');
            
            \Log::info('URLs SOAP generadas', [
                'base_url' => $baseUrl,
                'port' => $port,
                'host' => $host,
                'scheme' => $scheme
            ]);
            
            $options = [
                'uri' => $baseUrl . '/soap',
                'location' => $baseUrl . '/soap/service',
                'trace' => 1,
                'exceptions' => true,
                'soap_version' => $soapVersion,
                'encoding' => 'UTF-8',
                'features' => 0,
            ];

            // Crear SoapServer con contenido WSDL usando un archivo temporal
            try {
                // Crear un archivo temporal con el contenido del WSDL
                $tempFile = tempnam(sys_get_temp_dir(), 'wsdl_');
                file_put_contents($tempFile, $wsdlContent);
                
                // Crear SoapServer con el archivo temporal
                $server = new \SoapServer($tempFile, $options);
                \Log::info('SoapServer creado exitosamente con WSDL temporal');
                
                // El archivo temporal se eliminará automáticamente al finalizar el script
                register_shutdown_function(function() use ($tempFile) {
                    if (file_exists($tempFile)) {
                        @unlink($tempFile);
                    }
                });
            } catch (\Exception $e) {
                if (isset($tempFile) && file_exists($tempFile)) {
                    @unlink($tempFile);
                }
                \Log::error('Error al crear SoapServer: ' . $e->getMessage(), [
                    'options' => $options,
                    'wsdl_length' => strlen($wsdlContent)
                ]);
                throw new \Exception('Error al crear el servidor SOAP: ' . $e->getMessage());
            }
            
            $server->setObject($this->walletService);
            \Log::info('Objeto WalletSoapService asignado al SoapServer');
            
            // Obtener contenido sin procesar
            $rawContent = $request->getContent();
            
            // Validar XML antes de procesar
            libxml_use_internal_errors(true);
            $xml = @simplexml_load_string($rawContent);
            $xmlErrors = libxml_get_errors();
            libxml_clear_errors();
            
            if ($xml === false && !empty($xmlErrors)) {
                $errorMsg = 'XML inválido: ' . $xmlErrors[0]->message . ' en la línea ' . $xmlErrors[0]->line;
                \Log::error($errorMsg, [
                    'xml_preview' => substr($rawContent, 0, 500),
                    'line' => $xmlErrors[0]->line,
                    'column' => $xmlErrors[0]->column
                ]);
                throw new \Exception($errorMsg);
            }
            
            // Registrar la solicitud entrante para depuración
            \Log::info('Solicitud SOAP recibida', [
                'content_length' => strlen($rawContent),
                'content_type' => $request->header('Content-Type'),
                'soap_action' => $request->header('SOAPAction'),
                'preview' => substr($rawContent, 0, 500)
            ]);
            
            // Configurar manejo de errores para capturar todos los errores
            set_error_handler(function($errno, $errstr, $errfile, $errline) {
                \Log::error('Error PHP capturado durante SOAP: ' . $errstr, [
                    'errno' => $errno,
                    'file' => $errfile,
                    'line' => $errline
                ]);
                return false; // Continuar con el manejo de errores normal
            });
            
            ob_start();
            try {
                \Log::info('Iniciando procesamiento SOAP con SoapServer->handle()');
                $server->handle($rawContent);
                \Log::info('SoapServer->handle() completado');
            } catch (\SoapFault $e) {
                ob_end_clean();
                \Log::error('SoapFault capturado: ' . $e->getMessage(), [
                    'code' => $e->getCode(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'trace' => $e->getTraceAsString(),
                    'faultstring' => $e->faultstring ?? null,
                    'faultcode' => $e->faultcode ?? null
                ]);
                throw $e;
            } catch (\Throwable $e) {
                ob_end_clean();
                \Log::error('Error al procesar solicitud SOAP: ' . $e->getMessage(), [
                    'type' => get_class($e),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'trace' => $e->getTraceAsString()
                ]);
                throw $e;
            } finally {
                restore_error_handler();
            }
            
            $response = ob_get_clean();
            
            if (empty($response)) {
                \Log::warning('Respuesta SOAP vacía recibida', [
                    'output_buffer_length' => strlen(ob_get_contents() ?: '')
                ]);
                throw new \Exception('Respuesta SOAP vacía - el método no retornó datos');
            }
            
            \Log::info('Respuesta SOAP generada', [
                'response_length' => strlen($response),
                'preview' => substr($response, 0, 500)
            ]);
            
            return response($response, 200)
                ->header('Content-Type', 'application/soap+xml; charset=utf-8')
                ->header('SOAPAction', '""');
        } catch (\SoapFault $e) {
            \Log::error('Fallo SOAP: ' . $e->getMessage(), [
                'code' => $e->getCode(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
            
            // Retornar fallo SOAP apropiado
            $faultXml = '<?xml version="1.0" encoding="UTF-8"?>' .
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">' .
                '<soap:Body>' .
                '<soap:Fault>' .
                '<soap:Code><soap:Value>soap:Server</soap:Value></soap:Code>' .
                '<soap:Reason><soap:Text>' . htmlspecialchars($e->getMessage()) . '</soap:Text></soap:Reason>' .
                '</soap:Fault>' .
                '</soap:Body>' .
                '</soap:Envelope>';
            
            return response($faultXml, 500)
                ->header('Content-Type', 'application/soap+xml; charset=utf-8');
        } catch (\Exception $e) {
            \Log::error('Error SOAP: ' . $e->getMessage(), [
                'code' => $e->getCode(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
            
            // Retornar fallo SOAP apropiado
            $faultXml = '<?xml version="1.0" encoding="UTF-8"?>' .
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">' .
                '<soap:Body>' .
                '<soap:Fault>' .
                '<soap:Code><soap:Value>soap:Server</soap:Value></soap:Code>' .
                '<soap:Reason><soap:Text>' . htmlspecialchars($e->getMessage()) . '</soap:Text></soap:Reason>' .
                '</soap:Fault>' .
                '</soap:Body>' .
                '</soap:Envelope>';
            
            return response($faultXml, 500)
                ->header('Content-Type', 'application/soap+xml; charset=utf-8');
        }
    }
}
