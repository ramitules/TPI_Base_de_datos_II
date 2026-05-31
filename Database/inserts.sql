--DATOS PARA CARGAR EN LAS TABLAS--

INSERT INTO GruposMusculares (Nombre)
VALUES 
('Pecho / Pectorales'),
('Espalda / Dorsales'),
('Piernas / Tren Inferior'),
('Hombros / Deltoides'),
('Brazos (Bíceps/Tríceps)'),
('Core / Abdominales');
GO

INSERT INTO SuscripcionesEstados (Nombre)
VALUES 
('Activa'),
('Vencida'),
('Cancelada');
GO

INSERT INTO Roles (Rol)
VALUES 
('Admin'),
('Profesor'),
('Cliente'),
('Administrativo');
GO

INSERT INTO Planes (Nombre, PrecioMensual, DuracionDias)
VALUES 
('Pase Diario', 2500.00, 1),
('Plan Mensual Estándar', 18000.00, 30),
('Plan Mensual Pase Libre', 22000.00, 30),
('Trimestre Promocional', 15000.00, 90),
('Pase Libre Semestral', 13500.00, 180);
GO

INSERT INTO Usuarios (Nombre, Apellido, Email, CodUser, Contrasenia, FechaNacimiento, PesoCorporalKG, IdRol, FechaIngreso)
VALUES 
-- ROLES: 1 = Admin, 2 = Profesor, 3 = Cliente, 4 = Administrativo

-- Administradores (IdRol = 1, Peso = 0)
('Alejandro', 'Rossi', 'a.rossi@gym.com', 'ADM001', 'Pass123!', '1988-04-12', 0.00, 1, '2025-01-10 09:00:00'),
('Mariana', 'Fernández', 'm.fernandez@gym.com', 'ADM002', 'Admin2026', '1992-09-25', 0.00, 1, '2025-02-15 14:30:00'),

-- Profesores / Entrenadores (IdRol = 2, Peso = 0)
('Carlos', 'Mendoza', 'c.mendoza@gym.com', 'PRF001', 'ProfeCar1', '1985-11-05', 0.00, 2, '2025-03-01 08:15:00'),
('Laura', 'Gómez', 'l.gomez@gym.com', 'PRF002', 'LauFit2026', '1990-06-20', 0.00, 2, '2025-06-10 16:00:00'),
('Christian', 'Díaz', 'c.diaz@gym.com', 'PRF003', 'ChrisTrain', '1993-03-14', 0.00, 2, '2025-08-22 07:30:00'),

-- Administrativos / Recepción (IdRol = 4, Peso = 0)
('Florencia', 'Herrera', 'f.herrera@gym.com', 'REC001', 'FlorGym2', '1995-05-14', 0.00, 4, '2026-01-20 11:45:00'),
('Diego', 'Romero', 'd.romero@gym.com', 'REC002', 'DiegoStart', '1991-12-01', 0.00, 4, '2026-02-02 16:00:00'),

-- Clientes (IdRol = 3, Poseen Peso Corporal Real)
('Sofía', 'Benítez', 'sofia.b@email.com', 'CLI001', 'Sofi1998', '1998-07-19', 58.70, 3, '2026-01-05 10:00:00'),
('Lucas', 'Giménez', 'lucas.g@email.com', 'CLI002', 'Luquitas94', '1994-02-28', 78.40, 3, '2026-01-12 18:20:00'),
('Camila', 'Maidana', 'camila.m@email.com', 'CLI003', 'Cami2000', '2000-03-22', 55.20, 3, '2026-02-10 09:30:00'),
('Martín', 'Silva', 'martin.s@email.com', 'CLI004', 'Tincho87', '1987-08-30', 95.10, 3, '2026-02-18 20:15:00'),
('Valentina', 'Ríos', 'vale.rios@email.com', 'CLI005', 'ValeR96', '1996-10-10', 64.80, 3, '2026-03-01 07:00:00'),
('Facundo', 'Castro', 'facu.c@email.com', 'CLI006', 'Facu1993', '1993-01-15', 83.90, 3, '2026-03-05 15:30:00'),
('Julieta', 'Acosta', 'juli.acosta@email.com', 'CLI007', 'JuliFit97', '1997-11-23', 61.30, 3, '2026-03-12 08:00:00'),
('Gonzalo', 'Pereyra', 'gonza.p@email.com', 'CLI008', 'Gonza91', '1991-04-05', 89.50, 3, '2026-03-18 19:45:00'),
('Agustina', 'Sánchez', 'agus.s@email.com', 'CLI009', 'AgusS99', '1999-09-02', 53.40, 3, '2026-03-25 10:30:00'),
('Ezequiel', 'López', 'eze.lopez@email.com', 'CLI010', 'Eze power', '1990-02-17', 102.60, 3, '2026-04-02 21:00:00'),
('Micaela', 'Suárez', 'mica.s@email.com', 'CLI011', 'MicaFit01', '2001-01-28', 57.00, 3, '2026-04-10 14:15:00'),
('Tomás', 'Verón', 'tomas.v@email.com', 'CLI012', 'TomyV89', '1989-06-11', 76.20, 3, '2026-04-15 17:00:00'),
('Natalia', 'Blanco', 'naty.b@email.com', 'CLI013', 'Naty1994', '1994-10-05', 68.90, 3, '2026-04-20 09:15:00');
GO

INSERT INTO Ejercicios (Nombre, IdGrupoMuscular)
VALUES 
('Press de Banca con Barra', 1),
('Press Inclinado con Mancuernas', 1),
('Aperturas en Polea Alta (Cruces)', 1),

('Dominadas Pronas', 2),
('Remo con Barra', 2),
('Jalón al Pecho en Polea', 2),

('Sentadilla Libre con Barra', 3),
('Prensa de Piernas 45 Grados', 3),
('Sillón de Extensiones de Cuádriceps', 3),
('Peso Muerto Rumano con Mancuernas', 3),

('Press Militar con Barra', 4),
('Vuelos Laterales con Mancuernas', 4),
('Pájaros en Polea (Deltoides Posterior)', 4),

('Curl de Bíceps con Barra W', 5),
('Curl de Bíceps en Banco Scott', 5),
('Extensiones de Tríceps en Polea Alta', 5),
('Fondos en Paralelas para Tríceps', 5),

('Plancha Abdominal Isométrica', 6);
GO

INSERT INTO Rutinas (Nombre, IdUsuario, FechaCreacion)
VALUES 
-- Rutinas generales (IdUsuario es NULL)
('Rutina Fullbody Principiantes', NULL, '2025-01-15 10:00:00'),
('Torso / Pierna Avanzado', NULL, '2025-02-20 11:30:00'),
('Rutina de Fuerza (5x5)', NULL, '2025-03-05 09:15:00'),

-- Rutinas personalizadas (IDs del script de Usuarios)
('Hipertrofia Piernas - Sofía', 4, '2026-01-06 18:00:00'),
('Acondicionamiento General - Lucas', 5, '2026-01-13 19:45:00'),
('Definición / Quema Calórica - Florencia', 6, '2026-01-22 15:30:00'),
('Fuerza Máxima - Diego', 7, '2026-02-03 20:00:00'),
('Rutina Adaptada - Martín', 9, '2026-02-19 10:20:00');
GO

INSERT INTO Suscripciones (IdUsuario, IdPlan, IdSuscripcionEstado, FechaInicio, FechaVencimiento)
VALUES 
(4, 2, 2, '2026-01-05', '2026-02-04'),
(5, 3, 2, '2026-01-12', '2026-02-11'),
(6, 2, 2, '2026-01-20', '2026-02-19'),
(7, 2, 2, '2026-02-02', '2026-03-04'),
(8, 4, 2, '2026-02-10', '2026-05-11'), 
(4, 3, 1, '2026-05-01', '2026-05-31'), 
(5, 3, 1, '2026-05-12', '2026-06-11'), 
(6, 2, 1, '2026-05-05', '2026-06-04'), 
(9, 5, 1, '2026-02-18', '2026-08-17'), 
(10, 2, 1, '2026-04-25', '2026-05-25'),
(11, 3, 1, '2026-05-05', '2026-06-04'), 
(12, 2, 1, '2026-05-12', '2026-06-11'), 
(13, 2, 1, '2026-05-15', '2026-06-14'), 
(14, 1, 2, '2026-04-02', '2026-04-03'),
(15, 1, 2, '2026-04-10', '2026-04-11');
GO



INSERT INTO RutinaEjercicios (IdEjercicio, ObjetivoSeries, ObjetivoRepeticiones, OrdenEjercicio)
VALUES 
(7,  3, 10, 1),
(1,  3, 12, 2),
(6,  3, 10, 3),
(12, 2, 12, 4),
(18, 3, 45, 5),
(1,  4, 8,  1),
(5,  4, 8,  2),
(11, 3, 10, 3),
(14, 3, 12, 4),
(16, 3, 12, 5),
(7,  4, 8,  1),
(8,  3, 12, 2),
(10, 4, 10, 3),
(9,  3, 15, 4),
(7,  5, 5,  1),
(1,  5, 5,  2),
(5,  5, 5,  3);
GO

INSERT INTO SesionesEntrenamiento (IdUsuario, IdRutina, FechaHoraInicio, FechaHoraFin)
VALUES 
(4, 4, '2026-01-08 18:30:00', '2026-01-08 19:45:00'),
(5, 5, '2026-01-15 19:00:00', '2026-01-15 20:15:00'),
(6, 6, '2026-01-25 16:00:00', '2026-01-25 17:00:00'),
(7, 7, '2026-02-05 20:15:00', '2026-02-05 21:45:00'),
(4, 4, '2026-02-12 18:15:00', '2026-02-12 19:30:00'),
(9, 8, '2026-02-22 09:30:00', '2026-02-22 10:45:00'),
(7, 7, '2026-03-02 20:00:00', '2026-03-02 21:30:00'),
(5, NULL, '2026-03-10 19:30:00', '2026-03-10 20:30:00'),
(10, NULL, '2026-04-26 08:00:00', '2026-04-26 09:00:00'),
(4, 1, '2026-05-02 10:00:00', '2026-05-02 11:15:00'),
(11, 2, '2026-05-08 17:00:00', '2026-05-08 18:20:00'),
(12, 2, '2026-05-14 19:15:00', '2026-05-14 20:30:00');
GO

INSERT INTO SeriesCompletadas (IdSesionEntrenamiento, IdEjercicio, PesoLevantadoKG, RepeticionesLogradas, RIR, EsRecordPersonal)
VALUES 
(1, 7, 40, 10, 3, 0), 
(1, 7, 50, 8,  2, 0),
(1, 7, 50, 8,  1, 0),
(1, 7, 55, 6,  0, 1),
(1, 8, 100, 12, 2, 0),
(1, 8, 120, 12, 1, 0),
(1, 8, 130, 10, 0, 1),
(4, 7, 100, 5, 2, 0),
(4, 7, 100, 5, 2, 0),
(4, 7, 105, 5, 1, 0),
(4, 7, 105, 5, 1, 0),
(4, 7, 110, 5, 0, 1),
(4, 1, 80, 5, 2, 0),
(4, 1, 85, 5, 1, 0),
(4, 1, 85, 5, 1, 0),
(4, 1, 90, 4, 0, 0),
(8, 14, 25, 12, 2, 0),
(8, 14, 25, 10, 1, 0),
(8, 14, 30, 8,  0, 0),
(8, 16, 20, 15, 3, 0),
(8, 16, 25, 12, 2, 0),
(8, 16, 25, 12, 1, 0),
(11, 1, 60, 8, 2, 0),
(11, 1, 65, 8, 2, 0),
(11, 1, 70, 8, 1, 0),
(11, 1, 70, 7, 0, 0),
(11, 5, 50, 10, 2, 0),
(11, 5, 55, 10, 1, 0),
(11, 5, 60, 8,  0, 0);
GO
