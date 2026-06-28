CREATE DATABASE GestionGimnasio
Collate Latin1_General_CI_AI
GO

USE GestionGimnasio;
GO

-- Tablas --

CREATE TABLE GruposMusculares (  -- Pecho, biceps, etc.
	IdGruposMusculares	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 				NVARCHAR(100) NOT NULL,
	PRIMARY KEY (IdGruposMusculares)
);
GO

CREATE TABLE SuscripcionesEstados (  -- Activa, vencida, etc.
	IdSuscripcionesEstados	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 					NVARCHAR(50) NOT NULL
	PRIMARY KEY (IdSuscripcionesEstados)
);
GO

CREATE TABLE Roles (  -- Entrenador, Administrativo, etc.
	IdRoles		TINYINT NOT NULL IDENTITY(1,1),
	Nombre 		NVARCHAR(50) NOT NULL
	PRIMARY KEY (IdRoles)
);
GO

CREATE TABLE Planes (  -- Los tipos de suscripcion que ofrece el gimnasio
	IdPlanes		SMALLINT NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150) NOT NULL UNIQUE,
	PrecioMensual 	DECIMAL(8,2) NOT NULL DEFAULT 0,
	DuracionDias 	SMALLINT DEFAULT 0
	PRIMARY KEY (IdPlanes)
);
GO

CREATE TABLE Usuarios (  -- Almacena tanto a los clientes como al staff (entrenadores, administradores)
	IdUsuarios			INTEGER NOT NULL IDENTITY(1,1),
	Nombre		 		NVARCHAR(70) NOT NULL,
	Apellido	 		NVARCHAR(70) NOT NULL,
	Email 				NVARCHAR(150) NOT NULL UNIQUE,
	FechaNacimiento 	DATE NOT NULL,
	PesoCorporalKG 		DECIMAL(5,2) NOT NULL DEFAULT 0,
	IdRol 				TINYINT NOT NULL,
	FechaIngreso 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Activo				BIT NOT NULL DEFAULT 1
	PRIMARY KEY (IdUsuarios),
	FOREIGN KEY(IdRol) REFERENCES Roles(IdRoles)
);
GO

CREATE TABLE Suscripciones (  -- Tabla puente (con datos extra) que relaciona a los usuarios con los planes a lo largo del tiempo
	IdSuscripciones		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 			INTEGER NOT NULL,
	IdPlan 				SMALLINT NOT NULL,
	IdEstado 			TINYINT NOT NULL,
	FechaInicio			DATE NOT NULL,
	FechaVencimiento 	DATE NOT NULL
	PRIMARY KEY (IdSuscripciones),
	FOREIGN KEY(IdEstado) REFERENCES SuscripcionesEstados(IdSuscripcionesEstados),
	FOREIGN KEY(IdPlan) REFERENCES Planes(IdPlanes),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios),
	CHECK (FechaVencimiento > FechaInicio),
);
GO

CREATE TABLE Ejercicios (  -- Un catalogo estandarizado de movimientos
	IdEjercicios	INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(200) NOT NULL,
	IdGrupoMuscular	TINYINT,
	LinkExplicacion	NVARCHAR(255)  -- Link a la pagina que explica como realizar el ejercicio
	PRIMARY KEY (IdEjercicios),
	FOREIGN KEY(IdGrupoMuscular) REFERENCES GruposMusculares(IdGruposMusculares),
	CONSTRAINT CK_Ejercicios_LinkExplicacion
		CHECK (LinkExplicacion LIKE 'https://www.simplyfitness.com/es/pages/%')
);
GO

CREATE TABLE Rutinas (  -- Plantillas de entrenamiento que un entrenador puede asignar o que el usuario arma (Ej: Empuje/Tiron/Piernas)
	IdRutinas		INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150) NOT NULL,
	IdUsuario 		INTEGER, --<-- Si este atributo es NULL, es una rutina general que puede elegir cualquier cliente/entrenador.
	FechaCreacion 	DATETIME NOT NULL,
	Dia				VARCHAR(15), --<-- Si este atributo es NULL, es rutina libre (lo puede realizar cualquier dia de la semana).
	Activo			BIT NOT NULL DEFAULT 1
	PRIMARY KEY (IdRutinas),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios)
);
GO

CREATE TABLE RutinaEjercicios (  -- Asigna los ejercicios específicos a una plantilla de rutina
	IdRutinasEjercicios		INTEGER NOT NULL IDENTITY(1,1),
	IdEjercicio 			INTEGER NOT NULL,
	IdRutina				INTEGER NOT NULL,
	ObjetivoKG				DECIMAL(6, 2) DEFAULT 1,
	ObjetivoSeries 			SMALLINT DEFAULT 1,
	ObjetivoRepeticiones 	SMALLINT DEFAULT 1,
	OrdenEjercicio 			TINYINT DEFAULT 1 --<-- Si debe ser el primer ejercicio de la rutina del dia, el ultimo, etc.
	PRIMARY KEY (IdRutinasEjercicios),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicios),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(IdRutinas)
);
GO

CREATE TABLE SesionesEntrenamiento (  -- Registra el momento exacto en que un usuario pisa el gimnasio y entrena
	IdSesionesEntrenamiento		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 					INTEGER NOT NULL,
	IdRutina 					INTEGER,
	FechaHoraInicio 			DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FechaHoraFin 				DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
	PRIMARY KEY (IdSesionesEntrenamiento),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(IdRutinas),
	CHECK (FechaHoraFin >= FechaHoraInicio),
);
GO

CREATE TABLE SeriesCompletadas (  -- Guarda cada serie efectiva que hace el usuario. Ideal analisis
	IdSeriesCompletadas		INTEGER NOT NULL IDENTITY(1,1),
	IdSesion 				INTEGER NOT NULL,
	IdEjercicio 			INTEGER NOT NULL,
	PesoLevantadoKG 		DECIMAL(6, 2) NOT NULL DEFAULT 0,
	RepeticionesLogradas 	SMALLINT NOT NULL DEFAULT 0,
	RIR 					TINYINT,  --<-- Reps In Reserve, o repeticiones de reserva que le quedaban antes de llegar al fallo.
	EsRecordPersonal 		BIT NOT NULL DEFAULT 0
	PRIMARY KEY (IdSeriesCompletadas),
	FOREIGN KEY(IdSesion) REFERENCES SesionesEntrenamiento(IdSesionesEntrenamiento),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicios)
);
GO

CREATE TABLE AccesoUsuarios (  -- Guarda el codigo de usuario y su contraseña para el acceso y/o demas validaciones
	IdUsuarios				INT NOT NULL,
	Pass		 			VARCHAR (200) NOT NULL,
	FOREIGN KEY(IdUsuarios) REFERENCES Usuarios (IdUsuarios)
);
GO

--Tablas de auditoria (Probando)
--Modificacion y/o eliminacion de usuarios
CREATE TABLE Auditoria_Usuarios(
  IdAuditoria INT IDENTITY(1,1),
  IdUsuarioAfectado INT,
  Accion VARCHAR(10),
  DatosAnteriores VARCHAR(MAX),
  DatosNuevos VARCHAR(MAX),
  IdUsuarioApp INT NULL,
  UsuarioBD VARCHAR(100) DEFAULT SUSER_SNAME(),
  FechaHora DATETIME DEFAULT GETDATE(),
  DireccionIP VARCHAR(45),

  PRIMARY KEY(IdAuditoria)
  );
GO

--Cambios de pass
CREATE TABLE Auditoria_Pass(
  IdHistorial INT IDENTITY(1,1),
  IdUsuarioModificado INT,
  Pass VARCHAR(255),
  IdUsuarioModificador INT NULL,
  UsuarioBD VARCHAR(100) DEFAULT SUSER_SNAME(),
  FechaHora DATETIME DEFAULT GETDATE(),
  DireccionIP VARCHAR(45),

  PRIMARY KEY(IdHistorial)
  );
GO

--Errores que vienen de la app
CREATE TABLE Auditoria_Errores(
  IdLog INT IDENTITY(1,1),
  FechaHora DATETIME DEFAULT GETDATE(),
  Modulo VARCHAR(100),
  MensajeError VARCHAR(MAX),
  StackTrace VARCHAR(MAX),
  IdUsuarioLogueado INT NULL,
  UsuarioBD VARCHAR(100) DEFAULT SUSER_SNAME(),
  DatosEntrada VARCHAR(MAX),

  PRIMARY KEY(IdLog)
  );
GO