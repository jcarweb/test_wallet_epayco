-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-11-2025 a las 15:06:18
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `epayco_wallet`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clients`
--

CREATE TABLE `clients` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `document` varchar(50) NOT NULL,
  `fullName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phoneNumber` varchar(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `clients`
--

INSERT INTO `clients` (`id`, `document`, `fullName`, `email`, `phoneNumber`, `created_at`, `updated_at`) VALUES
(1, '1234567890', 'Juan Hernandez', 'juan@testepayco.com', '3005555556', '2025-11-16 10:20:09', '2025-11-16 10:20:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(2, '2025_15_11_000000_create_sessions_table', 1),
(3, '2025_15_11_000001_create_clients_table', 1),
(4, '2025_15_11_000002_create_wallets_table', 1),
(5, '2025_15_11_000003_create_payment_sessions_table', 1),
(6, '2025_15_11_000004_create_transactions_table', 1),
(7, '2025_15_11_000005_create_cache_table', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `payment_sessions`
--

CREATE TABLE `payment_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `walletId` bigint(20) UNSIGNED NOT NULL,
  `sessionId` varchar(100) NOT NULL,
  `token` varchar(6) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` enum('pending','confirmed','expired') NOT NULL DEFAULT 'pending',
  `expiresAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `confirmedAt` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `payment_sessions`
--

INSERT INTO `payment_sessions` (`id`, `walletId`, `sessionId`, `token`, `amount`, `status`, `expiresAt`, `confirmedAt`, `created_at`, `updated_at`) VALUES
(1, 1, '05c6c777-81ce-4a2e-882a-52045bc20999', '898308', 50000.00, 'confirmed', '2025-11-16 06:39:40', '2025-11-16 10:39:40', '2025-11-16 10:35:57', '2025-11-16 10:39:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('3Zu9zchOPRGpRxn4crOOcsD8VoyVZAQikawFdLde', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV0tUU1hCV3FuZFhmdDZ5SzlTNHZxaUFZTjJ2YzVERllPajh4QzJZVCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272486),
('53OJO19TPc3Qnmy9131SPxX9cvyh7kjN8ShjILNt', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiN1hWS3JlcENvUnRlTjljamZpOVFDcFF4cDFvUFMwQlZ1ckFUNzJRWiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276470),
('612YIP010h9gqJGD2Q3H4ALMi2umQ0JSEUeSIS73', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiMWxsbkZQY01lWGRhSzJDSk5YMXEwR0doUmRyeFZHSE9CSnRzZEQ2aCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272044),
('6nGuGqny0rpA3o9lFmLjzzI8n7sE2tlUqTSjoqDd', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoidG5HaHNqdm9aY1pTbkdnSjZ0WjNGVFBYWFhvTzByT3g5TUdURFpGaCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275321),
('73K4c9PKQXRLGQPc2aMbuRy3OW05qmEMXE6brnlF', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiS3dOUnI2eklSUmZzNDFqVE1INjIxSW9ESEFteG95azVtc1B5VVM4cyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272282),
('7pbjxVO5me4YlkF83Ti7zx8Lmi8WC0cUZPYPfZly', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoic0pHUEdjWDFuY3poUWloYTdIS2hoWUtKZ2Z1V0hEeFpEN1VkTFQ1NSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275857),
('7sR1WwV0SBprqJACRMDGtLsNTYeTk9CCZHXS7Bol', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiOGYzd2ZlbDRQZXVHZTlaUWhXam40T1U1cktWUHkwVG9lOXozV0l2aSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275570),
('7TUuaNwg0fziL7j13znsaFYCnrQ7XjSSknEyGgm9', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiT29kckFEbXNaaDFVME1HbTltOUR3aFNwYTk3Y2xPYUx2YnBJYlpMVCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763274822),
('7xNxWAyTic3k6BCyvVY3efmVlhoe4GSAFb8uZfkq', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1Z1RVA3d0VyR1RwQm9rUVdzaVVBM1FUWEozMGxvZ1lIWjZ1NnJGMCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272281),
('9ftqkQddW22EiZIMhrZ57KBe9TXLL65T7qxr9gcX', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSkRWcVBmaUdteWIzbEROaFhBWTJSWTMyM0x2NDBaVDdvbXMzcDFFTiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272911),
('Aio9A483pucJsERn98qRt2sNrIwswdxhebB0UIGT', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidVRYU3JhTVZVN1BIQmNKR2JQeHRIYWRuYk5rRGZxcVQ3Zk5NR0lMTCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272587),
('aStf4XIpmQrL7QGGnhLFYAJ4N7zekPI2qi9qMu0b', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiWkF6blBTeE4za3Jlb00wVDZDeGdocFlRYXQ0RWtXTkVheG8zRTkwNiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275180),
('BAjpLOAa2mTXag406N0xFyxOGirOsEh2GJxuOIn7', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZUxTMmY3dUdRUFFSMjZNbDY0NXpPN0oxTHZLSWw3N2ZOZnIxSXZxbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273116),
('bmvwtiHci92I801dRNAZmhI8AfuEgudwSFWsRbRR', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoic3lCWmFUWkRYSlZBRDB1dldtdkZLTEJxbnllREd3SmY2S2p6cW9oRiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271181),
('C0tsqpOlVh6ZATnc7tzvEA7dDbF5oXny3TJTTpoX', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiSk9aaHNUTDVlSzJnRDhwMVc4c3BmSjhINDRkNkV4V3Y4WlRtRnF3QyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276053),
('d8Fb01NY2W8OCeKY22lb5MEU0rsHaDnTFq5K9Inm', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVlBQWXRLWlZXdWoxZ1laTEpieUJ0Y3VVZEtVSUNiZ2hndUoyWVR4eiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272384),
('daY3C0soqnOMG2ZBYyetmJfQv1yEcFmdjfptH21d', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiMXpEZXhCOFBSQzFyM2dIaEgwRHlVMjB1SGcydXFVejMxSU1rYW5zUyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276622),
('eWYkEY2m10lgPCUqoSfYh2rO4fDpqmuiNH8ajqsY', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiQkt2aDJpZDQ2T1BrNFFtRllUWGZsdjF3c2pnQ0x6SEpiMGlJSEdqZCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271910),
('GV9x64EJC41Bmr1L1xoZibm4crjZHWQKnybwGgea', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoib1lEeFczZzlsNWJNNHJNeXZSS3B5a1ZRVXR2cE02Y2hQYnM0UTFsZyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272487),
('GyzGQGlC8Va8IrExVsLyf5B8MN94Qx7z9X7IBwxE', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2IwYmJuaktWaXNCaUdNZGZkeWxtVFNlSGc2RVVoeVlaNkVrWjhwMSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272562),
('hLSJVE23obNzVkEphnI6FEtQRJmg58Tb1qf6xfsP', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiZ1ZleG8wQkNvSlYxSkpISkczU0wwd29tM0tJS2hFRk1SNmVIUEpyWCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763273186),
('ibaRILscWysG1L3w5qLrtPhq6JZCELx1qvaCTAB8', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoia0pnMWNvTlFlemNOYzhiMlJPVXZhQU5jOEZjQWI3WDVHWm1ibUE4RiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275077),
('IJbICfI9G1YoTVcL8nZso9waogyr2Nomdoih86Fx', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUUV3czVTZnBMVDhjd3dMT2YyNVB6bkhhM3F1dG5xdExJbHBwSHpmcyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763274009),
('jcf6EKSc6PgRC6iUsGYqTpsqv05QY3oTwQRVVwd5', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiSHdobkpEbTJmNFhTR3BaTVdYWkdGd1NacUJEUHY3eTFudk9PNHpNWiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275243),
('jEu9C7UshMIar0wa8251lNB7oY0yFk2XPSVud4BG', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoidmhydHM2UFJvdnBoNmdvUDZyWm5wUzlkZ1pnZFQ4SEZsOElYS283YiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271760),
('JfglXhHdPbHoe790IqUjjgdKW9NYhITZW2oWrbdv', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOVpXZUtUQ2x3ZFFTVHpLRmw2dDhxWURUWHRmeFdLVGViVU1OTnhTbyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273437),
('jordsM7xyzw1muqHl6FObj8BBAeec2bMNdXUlTBz', NULL, '127.0.0.1', 'curl/8.16.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidG10b1U5dTdCVlVWYUp4VjJjcjVBdGVSQXpRRDR2bmtKNHIyYnQ3TCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763271122),
('k1T8zVGgGil8wGEXuVAOR4d09E0JVBkJUuKZT3Mp', NULL, '127.0.0.1', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNFlyUEVOZlUxUUhPeEM0MFlYMWJudTJySENhdXBBT0Jvd2J0NGJociI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273792),
('lMSyfwINUEC5X68v0W6f2K5xOmYyuKb4md4c1ZZQ', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiY21nMVQyV3VtSGc5OFNLaWxNR3VhWTJwd0hySDN1UnVGN3JtN0ZCMSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271174),
('M0czvIaHmHeZUw0EHN9Y4vbivx2Tvp9Kf7211wsF', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiZzlDTFQwcEhOMWRjNFA3ZWlXem5iQlhPTFZ3b2VQZDlJQ09aRHVDdCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763273016),
('Mv1XOF44CznbfWkZISRIeONQ9sZDu30C4RqnZAkn', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiWVVKZ2tXZDdhTmJmNDF1OENjWXRCSVBmYXJnQnhEZ2xTV2hvYzlmdCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271066),
('mxkcfoqqJyMFfFagiRtVsfnqDw2obwZIGOhBhhdw', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoid1ZwdVoxSVRpbEo3WDBPTW9CejhzOXVKaHJNaVhqdWIwNjQ3c3ZWaiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276175),
('N2YXqltgxnEjqXNsSD5NyHbNRd6TMjDu6dwllJJK', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiRGlQMlBhczhqcG9kSDNNc25wN0IxMGRVVWVabkdJbGhNUjVIazdraCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763274960),
('oX2dKU2DOeIXWVzvtClCGTxzMvRTNKQc7z4enGwu', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoieHIwTFJ4cnFZRGpDOGZFZWtMZldtWnV5TEZnZ1FoSHlZVjdoNUxyYSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275667),
('P0JzBBXTtLvYusWYmtkhbMNYJ6uVunyeq0wtJQZl', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiTng1UmlTWUJMdXFJdWFmaFdnN0FVSGFINDl3STVOTjJ3dEhUTzFNYiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276251),
('PXAWzA6KOnxa4aSMQY4fycnufxq64M5ayKBA1k0l', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTE5ORm9xelRiaGd0Vnp6TGRFOVBmb1BtdExwZkQ5TFpHMHNiVjJocyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273016),
('q5Bx1uQG3P8tCGpvsGOcCTerV3peiaEfujeIamGi', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiZVFlTnFnRWlqdml4aHRKYU5MYkpMMW0zbE9ROWVHWk9HR29rOE1WViI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763274009),
('QqEEJaod05WllXbfiYPceobqrBAc60EAehnj6xju', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiaUlKYW5GRWJ2SmRDc2laN2FyZk1QalZ4T1ZWSDJBS2E1WkdEaXRSRSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272081),
('rma3tYGuDCBmhyJzNCgpbZvCM4epCHbCnI5bbS6J', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ2lpYVZmaVdxOUJiRGFuQTdwRDJnb0VjY2xVRUk4aTNjZ08zYVNWWiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273185),
('RNToov0ZFGtc4cTpLi0pmGk4DJfIVWL3NZL5lN0F', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiNmMyaGZrdGl4T2d5N01tZlhjc1ZCcjhkbGc3Z2hHR1ZhTTVtTE12WSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763275772),
('SAyhAVKCElG0qy3bnlGNX8Zx890fsXy3jYqLI5S7', NULL, '127.0.0.1', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVnBRNXoxTXRXZDNmNEFvU3E3SnlpaDVZREF5eFh5WmQxT2FyM1pJZyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273500),
('TXIIYxT76IpTSDp3WJaM3EuZpihJu9wZ7JZvCv6M', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoic1hvb2pDUGpBV09KbndRa0VsWEVHREhaWWplTzBVOTFUYU9PQUJuYSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763271821),
('U0tDghXPekDbBm21e5QRR2tlkqkivVThHTTvwGU6', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiUHdETWZxSE1zalpiYTVvc2JwQ3BJR3lCVjNYSWx4cG1nZk5LMkp0cyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272912),
('udqWsIPJ2Yl6pT9Weh6V3yfFk4UJYya9B5qNcifG', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYWplWFJsM2ZwWG5xazR0WEhkY0Z2Y1Y1YURlTXhnV1YwVHREUFJRSCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272080),
('UWFGm3ZEMolNvV1lfAJkFbVlTcLN13RO7ik5v4gN', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiSDFNUmtvcm5ib3Rva0F0Q3dRY3dIMXBEMWw0TDZFSllmT3dmV0JXciI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763273116),
('W6wm9I9iTZMCbvrpZlaWI0rVdUGI88dvZH9Eh4LY', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiSXJNeVYwSW9paUp6bW80a1NQaENHNVgxWnpNRTZ3ZGdqR1c5dEI3TyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272400),
('wkUAJrmplgS3WtoQcJRDklK8StjsvoKVnIWTwplh', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieGxuVUsxbWhuUVJaVnNQQm94VERTNHNuWU9yZFhuZE9Qd2QxWDVvRyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763273729),
('XiDq8l7UdElyS2QlqBR052M0yxEubERatlvCnMl2', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoidVVEdVlSczRJZENtQWF4dlEwOFBQQjR1R0lSMVlGeVYwUnlld3ZhSiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272384),
('xKCMJ2xFS6Bi4bQXKP4vNxCi6j77XfMSB8ZELPAh', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiMlA2eUhyUmsySGlqM3ZRVHVySGpDQnBSVWtSQUt3UWRHaXF1eEFacyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272008),
('xv1GUsRUzkHeo9BLQGq145uPWdbxA9dhjTRcVIhS', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNk5KeEw4NjZ4N3FKcm9mWGtVOEEySEY3TERNMGlKbXY2TlBCSjk1eiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763271065),
('y49AYhQPdhSMrel9K669iT8UGOEYqGeaLmo4tv5P', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiN0lRSmFwRk5jc21JaUZGUXQwYVpDdFdVOEk3azNPdDJ6Ym44ZWp3OSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272588),
('yT4NAAvsMAMvygfXPH78QglPMDBckLe9m8Qy86vD', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiSDgzeHVLd041S1ZKdE5GdUg3bDRWVEF2eXdzdXhjcWtGejR3V090YSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272563),
('ZfxnpsIZoXGcHLAmCU7D6gjKpcv6lF1TmERf6rNL', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiek1BbGlUcnA5cEplcjBRQzZUU2pEYkU4N29xcGMzM3ZpUXpRTmJkcSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763274002),
('zJqDezP7ilHO2kVTEMQ9MI0lrMEyNqSYAyGIngDK', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoid3JlVGxLU0V2N3MzMjFiRjlraFdxcDBUaHpEUm1XVTZ5bENqWENVeSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763276662),
('Zr0fBORhf8t6mWnsSOKXcum9kp51F29LdaoQzuyb', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMTh5UU0zdTlKRVdFQVNWelBSTm5BeWl3NzJqZGdYRXFyaGVkREF6YyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zb2FwL3dzZGwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1763272008),
('ZzxVeBwLyFqsntqG9HgGxvntc1IWHTNO9zVQ0C98', NULL, '127.0.0.1', 'node-soap/1.6.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiVDAxanVHTDV6ajVFZGxqUURONjl5czFqWnF2VnlCUzJXaVhZSGtydiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763272490);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `walletId` bigint(20) UNSIGNED NOT NULL,
  `type` enum('recharge','payment') NOT NULL DEFAULT 'recharge',
  `amount` decimal(15,2) NOT NULL,
  `balanceBefore` decimal(15,2) NOT NULL,
  `balanceAfter` decimal(15,2) NOT NULL,
  `sessionId` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transactions`
--

INSERT INTO `transactions` (`id`, `walletId`, `type`, `amount`, `balanceBefore`, `balanceAfter`, `sessionId`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 'recharge', 100000.00, 0.00, 100000.00, NULL, 'Recarga de billetera', '2025-11-16 10:33:42', '2025-11-16 10:33:42'),
(2, 1, 'payment', 50000.00, 100000.00, 50000.00, '05c6c777-81ce-4a2e-882a-52045bc20999', 'Pago confirmado', '2025-11-16 10:39:40', '2025-11-16 10:39:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `wallets`
--

CREATE TABLE `wallets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `clientId` bigint(20) UNSIGNED NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `wallets`
--

INSERT INTO `wallets` (`id`, `clientId`, `balance`, `created_at`, `updated_at`) VALUES
(1, 1, 50000.00, '2025-11-16 10:20:09', '2025-11-16 10:39:40');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `clients_document_unique` (`document`),
  ADD UNIQUE KEY `clients_email_unique` (`email`),
  ADD KEY `clients_document_index` (`document`),
  ADD KEY `clients_phonenumber_index` (`phoneNumber`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `payment_sessions`
--
ALTER TABLE `payment_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_sessions_sessionid_unique` (`sessionId`),
  ADD KEY `payment_sessions_walletid_foreign` (`walletId`),
  ADD KEY `payment_sessions_sessionid_index` (`sessionId`),
  ADD KEY `payment_sessions_status_index` (`status`);

--
-- Indices de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indices de la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_walletid_index` (`walletId`),
  ADD KEY `transactions_type_index` (`type`),
  ADD KEY `transactions_created_at_index` (`created_at`);

--
-- Indices de la tabla `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallets_clientid_index` (`clientId`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clients`
--
ALTER TABLE `clients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `payment_sessions`
--
ALTER TABLE `payment_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `payment_sessions`
--
ALTER TABLE `payment_sessions`
  ADD CONSTRAINT `payment_sessions_walletid_foreign` FOREIGN KEY (`walletId`) REFERENCES `wallets` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_walletid_foreign` FOREIGN KEY (`walletId`) REFERENCES `wallets` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `wallets_clientid_foreign` FOREIGN KEY (`clientId`) REFERENCES `clients` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
