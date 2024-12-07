-- Data Cleaning

ALTER TABLE layoffs RENAME TO layoffs_raw;

SELECT *
FROM layoffs_raw;

-- 1. Remove duplicates
-- 2. Standardise the data
-- 3. Remove null/blank values
-- 4. Remove unnecessary columns


CREATE TABLE layoffs_staging
LIKE layoffs_raw;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs_raw;

SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) -- back ticks around date because date is a keywordin MySQL
AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) -- back ticks around date because date is a keywordin MySQL
AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) -- back ticks around date because date is a keywordin MySQL
AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) -- back ticks around date because date is a keywordin MySQL
AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;

SELECT *
FROM layoffs_staging2;


-- Standardising data (finding issues in your data then fixing it)

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- this wasn't working for me

SELECT *
FROM layoffs_staging2
WHERE `date` = 'None';

UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'None';

SELECT *
FROM layoffs_staging2
WHERE `date` IS NULL;

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET
	company = NULLIF(company, 'None'),
	location = NULLIF(location, 'None'),
    industry = NULLIF(industry, 'None'),
    total_laid_off = NULLIF(total_laid_off, 'None'),
    percentage_laid_off = NULLIF(percentage_laid_off, 'None'),
    stage = NULLIF(stage, 'None'),
    country = NULLIF(country, 'None'),
    funds_raised_millions = NULLIF(funds_raised_millions, 'None');


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




















































