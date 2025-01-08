-- Exploratory Data Analysis EDA

	# Sample
SELECT *
FROM layoffs_staging2 
ORDER BY rand() LIMIT 5;

	# Registros totales
SELECT COUNT(*) total_rows
FROM layoffs_staging2;

	# Información general de la tabla
DESCRIBE layoffs_staging2;

	# Rango de Fechas en los Registros de Layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

	# Máximo número de personas despedidas y porcentaje máximo.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

	 # Registros en los que se despidió al 100% de los trabajadores
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC, company;

	# Total empleados despedidos por empresa
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

	# Total empleados despedidos por industria
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

	# Total empleados despedidos por pais
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

	# Total empleados despedidos por año
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

	# Total empleados despedidos por año y país
SELECT YEAR(`date`) , country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`), country
ORDER BY 3 DESC;

	# Total empleados despedidos por mes
SELECT substring(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

		-- Rolling_total
WITH Rolling_total AS
(
SELECT substring(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_tot
FROM Rolling_total;

	# Total empleados despedidos por empresa y año
SELECT company, year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
ORDER BY 3 DESC;

		-- Rank 5 por año
WITH Company_year (company, years, total_laid_off)AS 
(
SELECT company, year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE Ranking < 6;