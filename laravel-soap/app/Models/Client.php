<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Client extends Model
{
    protected $table = 'clients';
    
    protected $fillable = [
        'document',
        'fullName',
        'email',
        'phoneNumber',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function wallet(): HasOne
    {
        return $this->hasOne(Wallet::class, 'clientId');
    }
}

