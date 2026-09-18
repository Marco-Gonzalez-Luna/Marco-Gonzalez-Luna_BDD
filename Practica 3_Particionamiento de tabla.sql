/*GONZALEZ LUNA MARCO
  OLVERA VALDIVIA CRISTOBAL*/

USE covidHistorico2;
GO

select * from dbo.datoscovid where FECHA_INGRESO < '2020-01-01';

/* 
=============================================================================
FASE 1: CREACIÓN DE ESTRUCTURA FÍSICA (FILEGROUPS Y ARCHIVOS)
Se crean grupos de archivos para separar físicamente los datos por año.
=============================================================================
*/

-- 1.1 Agregar los grupos de archivos (Filegroups)
ALTER DATABASE covidHistorico2 ADD FILEGROUP FG_2020;
ALTER DATABASE covidHistorico2 ADD FILEGROUP FG_2021;
ALTER DATABASE covidHistorico2 ADD FILEGROUP FG_2022;
ALTER DATABASE covidHistorico2 ADD FILEGROUP FG_OTROS; -- Para datos < 2020 o > 2022
GO

-- 1.2 Asignar archivos físicos (.ndf) a cada grupo
-- NOTA: Asegúrate de que la carpeta 'C:\Data\' exista en tu servidor.
ALTER DATABASE covidHistorico2 ADD FILE (NAME = N'Data_2020', FILENAME = N'C:\Data\covid_2020.ndf') TO FILEGROUP FG_2020;
ALTER DATABASE covidHistorico2 ADD FILE (NAME = N'Data_2021', FILENAME = N'C:\Data\covid_2021.ndf') TO FILEGROUP FG_2021;
ALTER DATABASE covidHistorico2 ADD FILE (NAME = N'Data_2022', FILENAME = N'C:\Data\covid_2022.ndf') TO FILEGROUP FG_2022;
ALTER DATABASE covidHistorico2 ADD FILE (NAME = N'Data_Otros', FILENAME = N'C:\Data\covid_otros.ndf') TO FILEGROUP FG_OTROS;
GO

/* 
=============================================================================
FASE 2: REGLAS DE PARTICIONAMIENTO
=============================================================================
*/

-- 2.1 Definir la función de partición (Los límites de los años)
-- RANGE RIGHT: El valor límite pertenece al rango de la derecha (ej. '2021-01-01' cae en 2021).
CREATE PARTITION FUNCTION pf_covid_anios (DATE)
AS RANGE RIGHT FOR VALUES ('2020-01-01', '2021-01-01', '2022-01-01');
GO

-- 2.2 Definir el esquema de partición (Mapear función -> Filegroups)
CREATE PARTITION SCHEME ps_covid_anios
AS PARTITION pf_covid_anios
TO (FG_OTROS, FG_2020, FG_2021, FG_2022);
GO

/* 
=============================================================================
FASE 3: TABLA PARTICIONADA E ÍNDICES
=============================================================================
*/


-- 3.1 Crear la tabla final sobre el esquema de partición
CREATE TABLE covid_final (
    FECHA_ACTUALIZACION DATE,
    ID_REGISTRO VARCHAR(20),
    ORIGEN INT,
    SECTOR INT,
    ENTIDAD_UM INT,
    SEXO INT,
    ENTIDAD_NAC INT,
    ENTIDAD_RES INT,
    MUNICIPIO_RES INT,
    TIPO_PACIENTE INT,
    FECHA_INGRESO DATE NOT NULL,  
    FECHA_SINTOMAS DATE,
    FECHA_DEF VARCHAR(20),        
    INTUBADO INT,
    NEUMONIA INT,
    EDAD INT,
    NACIONALIDAD INT,
    EMBARAZO INT,
    HABLA_LENGUA_INDIG INT,
    INDIGENA INT,
    DIABETES INT,
    EPOC INT,
    ASMA INT,
    INMUSUPR INT,
    HIPERTENSION INT,
    OTRA_COM INT,
    CARDIOVASCULAR INT,
    OBESIDAD INT,
    RENAL_CRONICA INT,
    TABAQUISMO INT,
    OTRO_CASO INT,
    TOMA_MUESTRA_LAB INT,
    RESULTADO_LAB INT,
    TOMA_MUESTRA_ANTIGENO INT,
    RESULTADO_ANTIGENO INT,
    CLASIFICACION_FINAL INT,
    MIGRANTE INT,
    PAIS_NACIONALIDAD VARCHAR(100),
    PAIS_ORIGEN VARCHAR(100),
    UCI INT
) ON ps_covid_anios(FECHA_INGRESO); -- Se particiona por la fecha
GO

-- 3.2 Crear índice clúster alineado (Mejora drásticamente el rendimiento)
CREATE CLUSTERED INDEX idx_fecha_covid 
ON covid_final(FECHA_INGRESO) 
ON ps_covid_anios(FECHA_INGRESO);
GO

/* =============================================================================
FASE 4: CARGA DE DATOS Y VERIFICACIÓN
=============================================================================
*/

-- 4.1 Insertar datos desde la tabla temporal (limpiando comillas y transformando)
INSERT INTO covid_final (
    FECHA_ACTUALIZACION, ID_REGISTRO, ORIGEN, SECTOR, ENTIDAD_UM, SEXO, ENTIDAD_NAC, 
    ENTIDAD_RES, MUNICIPIO_RES, TIPO_PACIENTE, FECHA_INGRESO, FECHA_SINTOMAS, FECHA_DEF, 
    INTUBADO, NEUMONIA, EDAD, NACIONALIDAD, EMBARAZO, HABLA_LENGUA_INDIG, INDIGENA, 
    DIABETES, EPOC, ASMA, INMUSUPR, HIPERTENSION, OTRA_COM, CARDIOVASCULAR, OBESIDAD, 
    RENAL_CRONICA, TABAQUISMO, OTRO_CASO, TOMA_MUESTRA_LAB, RESULTADO_LAB, 
    TOMA_MUESTRA_ANTIGENO, RESULTADO_ANTIGENO, CLASIFICACION_FINAL, MIGRANTE, 
    PAIS_NACIONALIDAD, PAIS_ORIGEN, UCI
)
SELECT 
    TRY_CONVERT(DATE, REPLACE(FECHA_ACTUALIZACION, '"', '')),
    REPLACE(ID_REGISTRO, '"', ''),
    TRY_CONVERT(INT, REPLACE(ORIGEN, '"', '')),
    TRY_CONVERT(INT, REPLACE(SECTOR, '"', '')),
    TRY_CONVERT(INT, REPLACE(ENTIDAD_UM, '"', '')),
    TRY_CONVERT(INT, REPLACE(SEXO, '"', '')),
    TRY_CONVERT(INT, REPLACE(ENTIDAD_NAC, '"', '')),
    TRY_CONVERT(INT, REPLACE(ENTIDAD_RES, '"', '')),
    TRY_CONVERT(INT, REPLACE(MUNICIPIO_RES, '"', '')),
    TRY_CONVERT(INT, REPLACE(TIPO_PACIENTE, '"', '')),
    TRY_CONVERT(DATE, REPLACE(FECHA_INGRESO, '"', '')),
    TRY_CONVERT(DATE, REPLACE(FECHA_SINTOMAS, '"', '')),
    REPLACE(FECHA_DEF, '"', ''),
    TRY_CONVERT(INT, REPLACE(INTUBADO, '"', '')),
    TRY_CONVERT(INT, REPLACE(NEUMONIA, '"', '')),
    TRY_CONVERT(INT, REPLACE(EDAD, '"', '')),
    TRY_CONVERT(INT, REPLACE(NACIONALIDAD, '"', '')),
    TRY_CONVERT(INT, REPLACE(EMBARAZO, '"', '')),
    TRY_CONVERT(INT, REPLACE(HABLA_LENGUA_INDIG, '"', '')),
    TRY_CONVERT(INT, REPLACE(INDIGENA, '"', '')),
    TRY_CONVERT(INT, REPLACE(DIABETES, '"', '')),
    TRY_CONVERT(INT, REPLACE(EPOC, '"', '')),
    TRY_CONVERT(INT, REPLACE(ASMA, '"', '')),
    TRY_CONVERT(INT, REPLACE(INMUSUPR, '"', '')),
    TRY_CONVERT(INT, REPLACE(HIPERTENSION, '"', '')),
    TRY_CONVERT(INT, REPLACE(OTRA_COM, '"', '')),
    TRY_CONVERT(INT, REPLACE(CARDIOVASCULAR, '"', '')),
    TRY_CONVERT(INT, REPLACE(OBESIDAD, '"', '')),
    TRY_CONVERT(INT, REPLACE(RENAL_CRONICA, '"', '')),
    TRY_CONVERT(INT, REPLACE(TABAQUISMO, '"', '')),
    TRY_CONVERT(INT, REPLACE(OTRO_CASO, '"', '')),
    TRY_CONVERT(INT, REPLACE(TOMA_MUESTRA_LAB, '"', '')),
    TRY_CONVERT(INT, REPLACE(RESULTADO_LAB, '"', '')),
    TRY_CONVERT(INT, REPLACE(TOMA_MUESTRA_ANTIGENO, '"', '')),
    TRY_CONVERT(INT, REPLACE(RESULTADO_ANTIGENO, '"', '')),
    TRY_CONVERT(INT, REPLACE(CLASIFICACION_FINAL, '"', '')),
    TRY_CONVERT(INT, REPLACE(MIGRANTE, '"', '')),
    REPLACE(PAIS_NACIONALIDAD, '"', ''),
    REPLACE(PAIS_ORIGEN, '"', ''),
    TRY_CONVERT(INT, REPLACE(UCI, '"', ''))
FROM datoscovid
WHERE TRY_CONVERT(DATE, REPLACE(FECHA_INGRESO, '"', '')) IS NOT NULL;
GO

-- 4.2 VERIFICACIÓN CORREGIDA
SELECT 
    p.partition_number AS NumeroParticion,
    fg.name AS NombreFilegroup,
    p.rows AS TotalFilas
FROM sys.partitions p
JOIN sys.indexes i 
    ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.destination_data_spaces dds 
    ON p.partition_number = dds.destination_id 
    AND i.data_space_id = dds.partition_scheme_id -- 👈 ESTA ES LA LÍNEA MÁGICA
JOIN sys.filegroups fg 
    ON dds.data_space_id = fg.data_space_id
WHERE p.object_id = OBJECT_ID('covid_final')
ORDER BY p.partition_number;



-- 1. Encender el reporte de estadísticas de lectura
SET STATISTICS IO ON;
GO

-- 2. Hacer una consulta que solo busque datos del año 2021
-- Nota: Limpiar la caché primero para asegurar una lectura real del disco (opcional pero recomendado para la prueba)
DBCC DROPCLEANBUFFERS; 
GO

SELECT 
    ENTIDAD_RES, 
    COUNT(*) AS Total_Casos, 
    AVG(EDAD) AS Edad_Promedio
FROM covid_final cf
WHERE FECHA_INGRESO >= '2020-01-01' AND FECHA_INGRESO <= '2020-12-31'
GROUP BY ENTIDAD_RES
ORDER BY Total_Casos DESC;
GO

-- 3. Apagamos el reporte
SET STATISTICS IO OFF;
GO