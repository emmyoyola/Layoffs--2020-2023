-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any column


-- CREATE A COPY 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- 1. REMOVE DUPLICATES
	-- Encontrar filas que tienen todas las columnas repetidas
    
WITH duplicates_CTE AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_CTE
WHERE row_num > 1;


	-- Revisar uno de los resultados anteriores para confirmar si son duplicados

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


	-- Crear una nueva tabla que incluya la columna row_num en la que se pueda eliminar las filas con valor >1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` bigint DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 									# New colum
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;


-- 2. STANDARDIZING DATA
	
    -- company
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2;


	-- industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;
		
        
        -- Crypto
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


	-- Country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

	-- date
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;

	-- 3. NULL VALUES
    # Cambiar los '' por null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
    
    # Revisar si la misma compañía tiene una industria registrada
SELECT t1.company,	t1.industry, t2.company, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

	# Actualizar industry
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

 # Bally's Interactive es la única que queda sin industry porque no hay m´s registros de la misma empresa
SELECT *
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

# Eliminar los registros con total_laid_off y total_laid_off nulos
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND total_laid_off IS NULL;


	-- 4. REMOVE COLUMNS
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;