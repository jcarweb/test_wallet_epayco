<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SoapController;

Route::get('/soap/wsdl', [SoapController::class, 'wsdl']);
Route::post('/soap/service', [SoapController::class, 'service']);

