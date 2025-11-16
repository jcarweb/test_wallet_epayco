-- Base de datos: epayco_wallet
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS epayco_wallet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE epayco_wallet;

-- Tabla: clients
CREATE TABLE IF NOT EXISTS clients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    document VARCHAR(50) NOT NULL UNIQUE,
    fullName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phoneNumber VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_document (document),
    INDEX idx_phoneNumber (phoneNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: wallets
CREATE TABLE IF NOT EXISTS wallets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    clientId BIGINT UNSIGNED NOT NULL,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_clientId (clientId),
    CONSTRAINT fk_wallets_clientId FOREIGN KEY (clientId) REFERENCES clients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: payment_sessions
CREATE TABLE IF NOT EXISTS payment_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    walletId BIGINT UNSIGNED NOT NULL,
    sessionId VARCHAR(100) NOT NULL UNIQUE,
    token VARCHAR(6) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'expired') NOT NULL DEFAULT 'pending',
    expiresAt TIMESTAMP NOT NULL,
    confirmedAt TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_sessionId (sessionId),
    INDEX idx_status (status),
    CONSTRAINT fk_payment_sessions_walletId FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: transactions
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    walletId BIGINT UNSIGNED NOT NULL,
    type ENUM('recharge', 'payment') NOT NULL DEFAULT 'recharge',
    amount DECIMAL(15, 2) NOT NULL,
    balanceBefore DECIMAL(15, 2) NOT NULL,
    balanceAfter DECIMAL(15, 2) NOT NULL,
    sessionId VARCHAR(100) NULL DEFAULT NULL,
    description TEXT NULL DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_walletId (walletId),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    CONSTRAINT fk_transactions_walletId FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: sessions (para Laravel)
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: cache (para Laravel)
CREATE TABLE IF NOT EXISTS cache (
    `key` VARCHAR(255) PRIMARY KEY,
    value MEDIUMTEXT NOT NULL,
    expiration INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: cache_locks (para Laravel)
CREATE TABLE IF NOT EXISTS cache_locks (
    `key` VARCHAR(255) PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    expiration INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

