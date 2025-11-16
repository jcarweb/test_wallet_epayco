<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// Creación de la tabla de clientes para almacenar información de clientes - ePayco
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clients', function (Blueprint $table) {
            $table->id();
            $table->string('document', 50)->unique();
            $table->string('fullName', 255);
            $table->string('email', 255)->unique();
            $table->string('phoneNumber', 20);
            $table->timestamps();
            
            $table->index('document');
            $table->index('phoneNumber');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clients');
    }
};

