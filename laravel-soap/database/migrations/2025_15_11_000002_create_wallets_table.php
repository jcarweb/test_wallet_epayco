<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// Creación de la tabla de wallets para almacenar información de billeteras de clientes - ePayco
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clientId')->constrained('clients')->onDelete('cascade');
            $table->decimal('balance', 15, 2)->default(0.00);
            $table->timestamps();
            
            $table->index('clientId');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};

