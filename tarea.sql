-- =============================================
-- PASO 1: Limpieza inicial (eliminar objetos existentes)
-- =============================================

-- Eliminar tablas en orden de dependencia (primero las que tienen FK)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ranking CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE simulacros_examenes CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE recursos';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE usuario';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Eliminar secuencias
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_usuario';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_recurso';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_examen';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_ranking';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- =============================================
-- PASO 2: Creación de secuencias
-- =============================================

CREATE SEQUENCE seq_usuario START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_recurso START WITH 101 INCREMENT BY 1;
CREATE SEQUENCE seq_examen START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_ranking START WITH 1 INCREMENT BY 1;

-- =============================================
-- PASO 3: Creación de tablas
-- =============================================

-- Tabla USUARIO
CREATE TABLE usuario (
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    fecha_registro DATE DEFAULT SYSDATE,
    ultimo_acceso DATE,
    universidad VARCHAR2(100),
    logros VARCHAR2(50) CHECK (logros IN ('Novato', 'Avanzado', 'Experto'))
);

-- Tabla RECURSOS
CREATE TABLE recursos (
    id_recurso NUMBER PRIMARY KEY,
    titulo VARCHAR2(200) NOT NULL,
    descripcion VARCHAR2(500),  -- Corregido de "descriptcion" a "descripcion"
    tipo VARCHAR2(20) CHECK (tipo IN ('APUNTE', 'EXAMEN', 'PDF', 'WORD')),
    archivo VARCHAR2(100),
    fecha_publicacion DATE DEFAULT SYSDATE,
    curso VARCHAR2(100)
);

-- Tabla SIMULACROS_EXAMENES
CREATE TABLE simulacros_examenes (
    id_examen NUMBER PRIMARY KEY,
    duracion NUMBER NOT NULL, -- en minutos
    preguntas NUMBER NOT NULL,
    curso VARCHAR2(100) NOT NULL,
    puntaje NUMBER,
    id_usuario NUMBER,
    CONSTRAINT fk_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- Tabla RANKING (nueva)
CREATE TABLE ranking (
    id_ranking NUMBER PRIMARY KEY,
    posicion NUMBER NOT NULL,
    id_usuario NUMBER NOT NULL,
    puntaje_total NUMBER NOT NULL,
    tiempo_promedio NUMBER, -- en minutos
    nivel_logro VARCHAR2(50) CHECK (nivel_logro IN ('Bronce', 'Plata', 'Oro', 'Platino', 'Diamante')),
    fecha_actualizacion DATE DEFAULT SYSDATE,
    CONSTRAINT fk_ranking_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT uk_ranking_posicion UNIQUE (posicion),
    CONSTRAINT uk_ranking_usuario UNIQUE (id_usuario)
);

-- =============================================
-- PASO 4: Inserción de datos de ejemplo
-- =============================================

-- Insertar usuarios
INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad, logros)
VALUES (seq_usuario.NEXTVAL, 'Ana García', 'ana.garcia@example.com', 
        TO_DATE('2023-01-15', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-20', 'YYYY-MM-DD'), 
        'Universidad Nacional', 'Novato');

INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad, logros)
VALUES (seq_usuario.NEXTVAL, 'Carlos Méndez', 'carlos.mendez@example.com', 
        TO_DATE('2023-03-10', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-18', 'YYYY-MM-DD'), 
        'Universidad Tecnológica', 'Experto');

INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad, logros)
VALUES (seq_usuario.NEXTVAL, 'Luisa Fernández', 'luisa.fernandez@example.com', 
        TO_DATE('2022-11-05', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-19', 'YYYY-MM-DD'), 
        'Universidad Privada', 'Avanzado');

-- Insertar recursos
INSERT INTO recursos (id_recurso, titulo, descripcion, tipo, archivo, fecha_publicacion, curso)
VALUES (seq_recurso.NEXTVAL, 'Apuntes de Matemáticas', 'Conceptos básicos de álgebra lineal', 
        'APUNTE', 'matematicas.pdf', 
        TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'Matemáticas I');

INSERT INTO recursos (id_recurso, titulo, descripcion, tipo, archivo, fecha_publicacion, curso)
VALUES (seq_recurso.NEXTVAL, 'Examen Final 2022', 'Examen de física con soluciones', 
        'EXAMEN', 'fisica_examen.pdf', 
        TO_DATE('2023-01-20', 'YYYY-MM-DD'), 'Física General');

-- Insertar simulacros de exámenes
INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, curso, puntaje, id_usuario)
VALUES (seq_examen.NEXTVAL, 90, 30, 'Matemáticas I', 85, 1);

INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, curso, puntaje, id_usuario)
VALUES (seq_examen.NEXTVAL, 120, 40, 'Física General', 92, 2);

INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, curso, puntaje, id_usuario)
VALUES (seq_examen.NEXTVAL, 60, 20, 'Programación I', 78, 3);

-- Insertar datos en RANKING
INSERT INTO ranking (id_ranking, posicion, id_usuario, puntaje_total, tiempo_promedio, nivel_logro)
VALUES (seq_ranking.NEXTVAL, 1, 2, 920, 45, 'Platino');

INSERT INTO ranking (id_ranking, posicion, id_usuario, puntaje_total, tiempo_promedio, nivel_logro)
VALUES (seq_ranking.NEXTVAL, 2, 1, 850, 52, 'Oro');

INSERT INTO ranking (id_ranking, posicion, id_usuario, puntaje_total, tiempo_promedio, nivel_logro)
VALUES (seq_ranking.NEXTVAL, 3, 3, 780, 60, 'Plata');

-- =============================================
-- PASO 5: Consultas de verificación
-- =============================================

-- Consulta de ranking completo
SELECT r.posicion, u.nombre, r.puntaje_total, r.tiempo_promedio, r.nivel_logro
FROM ranking r
JOIN usuario u ON r.id_usuario = u.id_usuario
ORDER BY r.posicion;

-- Consulta de usuarios con sus puntajes
SELECT u.nombre, u.universidad, 
       COALESCE(MAX(s.puntaje), 0) AS mejor_puntaje,
       COALESCE(ROUND(AVG(s.puntaje),2), 0) AS promedio_puntaje,
       r.nivel_logro
FROM usuario u
LEFT JOIN simulacros_examenes s ON u.id_usuario = s.id_usuario
LEFT JOIN ranking r ON u.id_usuario = r.id_usuario
GROUP BY u.nombre, u.universidad, r.nivel_logro
ORDER BY mejor_puntaje DESC;

COMMIT;
