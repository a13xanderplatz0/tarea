-- =============================================
-- PASO 1: Limpieza inicial (eliminar objetos existentes)
-- =============================================

-- Eliminar tablas en orden de dependencia (primero las que tienen FK)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ranking CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Tabla ranking no eliminada o no existe.');
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE simulacros_examenes CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE recursos CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE curso CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE usuario CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Eliminar vistas
BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW vista_ranking_completo';
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

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_curso';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- =============================================
-- PASO 2: Creación de secuencias
-- =============================================

CREATE OR REPLACE SEQUENCE seq_usuario START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE SEQUENCE seq_recurso START WITH 101 INCREMENT BY 1;
CREATE OR REPLACE SEQUENCE seq_examen START WITH 1001 INCREMENT BY 1;
CREATE OR REPLACE SEQUENCE seq_curso START WITH 10001 INCREMENT BY 1;
CREATE OR REPLACE SEQUENCE seq_ranking START WITH 1 INCREMENT BY 1;

-- =============================================
-- PASO 3: Creación de tablas mejoradas
-- =============================================

-- Tabla CURSO
CREATE TABLE curso (
    id_curso NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    area VARCHAR2(100),
    CONSTRAINT uk_curso_nombre UNIQUE (nombre)
);

-- Tabla USUARIO
CREATE TABLE usuario (
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    fecha_registro DATE DEFAULT SYSDATE,
    ultimo_acceso DATE,
    universidad VARCHAR2(100)
);

-- Tabla RECURSOS
CREATE TABLE recursos (
    id_recurso NUMBER PRIMARY KEY,
    titulo VARCHAR2(200) NOT NULL,
    descripcion VARCHAR2(500),
    tipo VARCHAR2(20) CHECK (tipo IN ('APUNTE', 'EXAMEN', 'PDF', 'WORD')),
    archivo VARCHAR2(100),
    fecha_publicacion DATE DEFAULT SYSDATE,
    id_curso NUMBER NOT NULL,
    id_usuario NUMBER NOT NULL,
    CONSTRAINT fk_recurso_curso FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    CONSTRAINT fk_recurso_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla SIMULACROS_EXAMENES
CREATE TABLE simulacros_examenes (
    id_examen NUMBER PRIMARY KEY,
    duracion NUMBER NOT NULL, -- en minutos
    preguntas NUMBER NOT NULL,
    puntaje NUMBER,
    fecha_realizacion DATE DEFAULT SYSDATE,
    id_curso NUMBER NOT NULL,
    id_usuario NUMBER NOT NULL,
    CONSTRAINT fk_examen_curso FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    CONSTRAINT fk_examen_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla RANKING
CREATE TABLE ranking (
    id_ranking NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    nivel VARCHAR2(50) CHECK (nivel IN ('Bronce', 'Plata', 'Oro', 'Platino', 'Diamante')),
    fecha_actualizacion DATE DEFAULT SYSDATE,
    CONSTRAINT fk_ranking_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT uk_ranking_usuario UNIQUE (id_usuario)
);

-- =============================================
-- PASO 4: Creación de índices para mejorar rendimiento
-- =============================================

CREATE INDEX idx_recurso_curso ON recursos(id_curso);
CREATE INDEX idx_examen_usuario ON simulacros_examenes(id_usuario);
CREATE INDEX idx_examen_curso ON simulacros_examenes(id_curso);

-- =============================================
-- PASO 5: Creación de vistas para consultas comunes
-- =============================================

CREATE OR REPLACE VIEW vista_ranking_completo AS
SELECT 
    r.id_ranking, 
    u.nombre, 
    u.universidad,
    r.nivel, 
    r.fecha_actualizacion,
    COUNT(e.id_examen) AS examenes_realizados,
    NVL(MAX(e.puntaje), 0) AS mejor_puntaje,
    NVL(AVG(e.puntaje), 0) AS promedio_puntaje
FROM 
    ranking r
JOIN 
    usuario u ON r.id_usuario = u.id_usuario
LEFT JOIN 
    simulacros_examenes e ON u.id_usuario = e.id_usuario
GROUP BY 
    r.id_ranking, u.nombre, u.universidad, r.nivel, r.fecha_actualizacion
ORDER BY 
    r.id_ranking;

CREATE OR REPLACE VIEW vista_recursos_detallados AS
SELECT 
    r.id_recurso,
    r.titulo,
    r.tipo,
    c.nombre AS curso,
    c.area,
    u.nombre AS autor,
    r.fecha_publicacion
FROM 
    recursos r
JOIN 
    curso c ON r.id_curso = c.id_curso
JOIN 
    usuario u ON r.id_usuario = u.id_usuario;

-- =============================================
-- PASO 6: Inserción de datos de ejemplo
-- =============================================

-- Insertar cursos
INSERT INTO curso (id_curso, nombre, area)
VALUES (seq_curso.NEXTVAL, 'Matemáticas I', 'Ciencias Básicas');

INSERT INTO curso (id_curso, nombre, area)
VALUES (seq_curso.NEXTVAL, 'Física General', 'Ciencias Básicas');

INSERT INTO curso (id_curso, nombre, area)
VALUES (seq_curso.NEXTVAL, 'Programación I', 'Ingeniería');

-- Insertar usuarios
INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad)
VALUES (seq_usuario.NEXTVAL, 'Ana García', 'ana.garcia@example.com', 
        TO_DATE('2023-01-15', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-20', 'YYYY-MM-DD'), 
        'Universidad Nacional');

INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad)
VALUES (seq_usuario.NEXTVAL, 'Carlos Méndez', 'carlos.mendez@example.com', 
        TO_DATE('2023-03-10', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-18', 'YYYY-MM-DD'), 
        'Universidad Tecnológica');

INSERT INTO usuario (id_usuario, nombre, email, fecha_registro, ultimo_acceso, universidad)
VALUES (seq_usuario.NEXTVAL, 'Luisa Fernández', 'luisa.fernandez@example.com', 
        TO_DATE('2022-11-05', 'YYYY-MM-DD'), 
        TO_DATE('2023-06-19', 'YYYY-MM-DD'), 
        'Universidad Privada');

-- Insertar recursos
INSERT INTO recursos (id_recurso, titulo, descripcion, tipo, archivo, fecha_publicacion, id_curso, id_usuario)
VALUES (seq_recurso.NEXTVAL, 'Apuntes de Matemáticas', 'Conceptos básicos de álgebra lineal', 
        'APUNTE', 'matematicas.pdf', 
        TO_DATE('2023-02-15', 'YYYY-MM-DD'), seq_curso.CURRVAL, seq_usuario.CURRVAL);

INSERT INTO recursos (id_recurso, titulo, descripcion, tipo, archivo, fecha_publicacion, id_curso, id_usuario)
VALUES (seq_recurso.NEXTVAL, 'Examen Final 2022', 'Examen de física con soluciones', 
        'EXAMEN', 'fisica_examen.pdf', 
        TO_DATE('2023-01-20', 'YYYY-MM-DD'), 10002, 2);

-- Insertar simulacros
INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, puntaje, fecha_realizacion, id_curso, id_usuario)
VALUES (seq_examen.NEXTVAL, 90, 30, 85, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 10001, 1);

INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, puntaje, fecha_realizacion, id_curso, id_usuario)
VALUES (seq_examen.NEXTVAL, 120, 40, 92, TO_DATE('2023-03-02', 'YYYY-MM-DD'), 10002, 2);

INSERT INTO simulacros_examenes (id_examen, duracion, preguntas, puntaje, fecha_realizacion, id_curso, id_usuario)
VALUES (seq_examen.NEXTVAL, 60, 20, 78, TO_DATE('2023-03-03', 'YYYY-MM-DD'), 10003, 3);

-- Insertar ranking
INSERT INTO ranking (id_ranking, id_usuario, nivel, fecha_actualizacion)
VALUES (seq_ranking.NEXTVAL, 1, 'Oro', SYSDATE);

INSERT INTO ranking (id_ranking, id_usuario, nivel, fecha_actualizacion)
VALUES (seq_ranking.NEXTVAL, 2, 'Platino', SYSDATE);

INSERT INTO ranking (id_ranking, id_usuario, nivel, fecha_actualizacion)
VALUES (seq_ranking.NEXTVAL, 3, 'Plata', SYSDATE);

-- =============================================
-- PASO 7: Consultas de verificación con formato de tablas
-- =============================================

-- Configuración para mostrar resultados en formato de tabla
SET LINESIZE 150
SET PAGESIZE 100
COLUMN nombre FORMAT A20
COLUMN email FORMAT A25
COLUMN universidad FORMAT A20
COLUMN curso FORMAT A20
COLUMN area FORMAT A20
COLUMN autor FORMAT A15
COLUMN nivel FORMAT A10

-- Mostrar datos de todas las tablas con formato
PROMPT ====================
PROMPT TABLA DE USUARIOS
PROMPT ====================
SELECT * FROM usuario;

PROMPT 
PROMPT ====================
PROMPT TABLA DE CURSOS
PROMPT ====================
SELECT * FROM curso;

PROMPT 
PROMPT ====================
PROMPT TABLA DE RECURSOS
PROMPT ====================
SELECT r.id_recurso, r.titulo, r.tipo, c.nombre AS curso, u.nombre AS autor, 
       TO_CHAR(r.fecha_publicacion, 'DD/MM/YYYY') AS fecha_publicacion
FROM recursos r
JOIN curso c ON r.id_curso = c.id_curso
JOIN usuario u ON r.id_usuario = u.id_usuario;

PROMPT 
PROMPT ====================
PROMPT TABLA DE SIMULACROS DE EXAMEN
PROMPT ====================
SELECT e.id_examen, u.nombre AS usuario, c.nombre AS curso, e.preguntas, e.duracion, e.puntaje,
       TO_CHAR(e.fecha_realizacion, 'DD/MM/YYYY') AS fecha_realizacion
FROM simulacros_examenes e
JOIN usuario u ON e.id_usuario = u.id_usuario
JOIN curso c ON e.id_curso = c.id_curso;

PROMPT 
PROMPT ====================
PROMPT TABLA DE RANKING (VISTA COMPLETA)
PROMPT ====================
SELECT * FROM vista_ranking_completo;

PROMPT 
PROMPT ====================
PROMPT VISTA DE RECURSOS DETALLADOS
PROMPT ====================
SELECT * FROM vista_recursos_detallados;

-- Mostrar metadatos
PROMPT 
PROMPT ====================
PROMPT TABLAS DEL SISTEMA
PROMPT ====================
SELECT table_name FROM user_tables ORDER BY table_name;

PROMPT 
PROMPT ====================
PROMPT VISTAS DEL SISTEMA
PROMPT ====================
SELECT view_name FROM user_views ORDER BY view_name;

PROMPT 
PROMPT ====================
PROMPT ÍNDICES DEL SISTEMA
PROMPT ====================
SELECT index_name, table_name FROM user_indexes WHERE index_name NOT LIKE 'SYS_%' ORDER BY table_name, index_name;

COMMIT;