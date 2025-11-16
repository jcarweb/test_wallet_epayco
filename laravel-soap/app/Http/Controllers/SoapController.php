<?php
// Controlador SOAP para manejar solicitudes y respuestas SOAP en Laravel. -ePayco Juan Hernandez 
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
            $wsdlUrl = url('/soap/wsdl');
            $options = [
                'uri' => url('/soap'),
                'location' => url('/soap/service'),
                'trace' => 1,
                'exceptions' => true,
                'soap_version' => SOAP_1_2,
            ];

            $server = new \SoapServer($wsdlUrl, $options);
            $server->setObject($this->walletService);
            
            ob_start();
            $server->handle($request->getContent());
            $response = ob_get_clean();
            
            return response($response, 200)
                ->header('Content-Type', 'text/xml; charset=utf-8')
                ->header('SOAPAction', '""');
        } catch (\Exception $e) {
            \Log::error('SOAP Error: ' . $e->getMessage());
            return response('Error processing SOAP request', 500)
                ->header('Content-Type', 'text/xml; charset=utf-8');
        }
    }
}
