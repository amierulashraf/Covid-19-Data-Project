/*
COVID 19 Data Project

Skills used : JOIN, Subquery, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Data used in this project

SELECT continent, location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM covid_portfolio_project..covid_death
WHERE continent IS NOT NULL
ORDER BY 1, 2

SELECT new_vaccinations
FROM covid_portfolio_project..covid_vaccinations
WHERE continent IS NOT NULL



-- Total case vs total death over time in Malaysia
-- Percentage of death when infected over time in Malaysia

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100,2) AS death_percentage
FROM covid_portfolio_project..covid_death
WHERE location LIKE '%malaysia%'
ORDER BY date



-- Total case vs population
-- Show percentage of population infected over time per country

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS infected_population_percentage
FROM covid_portfolio_project..covid_death
WHERE continent IS NOT NULL
ORDER BY location, date



-- Countries highest infected population percentage, high to low

SELECT location, population, MAX(total_cases) AS case_total, 
MAX(ROUND((total_cases/population)*100, 2)) AS highest_infected_population_percentage
FROM covid_portfolio_project..covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC



-- Countries total death over population percentage, high to low

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS death_total, 
MAX(ROUND((CAST(total_deaths AS INT)/population)*100, 3)) AS population_death_percentage
FROM covid_portfolio_project..covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC



-- Total death count by continent

SELECT continent, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM covid_portfolio_project..covid_death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC




-- Global total case, total death and death percentage

SELECT 'World'AS location, SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_death, 
ROUND((SUM(CAST(new_deaths AS INT))/SUM(New_Cases))*100,2) AS death_percentage
FROM covid_portfolio_project..covid_death
WHERE continent is not null 




-- Rolling count of vaccination over time per country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS vaccination_rolling_count
FROM covid_portfolio_project..covid_death AS dea
JOIN covid_portfolio_project..covid_vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Rolling count of vaccination and percentage by population per country using subquery

SELECT continent, location, date, population, new_vaccinations, vaccination_rolling_count,
ROUND(((vaccination_rolling_count / population) * 100), 4) AS rolling_vaccination_percentage
FROM
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS vaccination_rolling_count
FROM covid_portfolio_project..covid_death AS dea
JOIN covid_portfolio_project..covid_vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL) AS sq
ORDER BY location, date



-- Rolling count of vaccination and percentage by population per country using CTE

WITH roll_vac (continent, location, date, population, new_vaccinations, vaccination_rolling_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS vaccination_rolling_count
FROM covid_portfolio_project..covid_death AS dea
JOIN covid_portfolio_project..covid_vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND(((vaccination_rolling_count / population) * 100), 4) AS rolling_vaccination_percentage
FROM roll_vac
ORDER BY location, date



-- Rolling count of vaccination and percentage by population per country using temp table

DROP TABLE IF EXISTS #vaccination_rolling_count
CREATE TABLE #vaccination_rolling_count
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population FLOAT,
new_vaccinations INT,
vaccination_rolling_count INT
)

INSERT INTO #vaccination_rolling_count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS vaccination_rolling_count
FROM covid_portfolio_project..covid_death AS dea
JOIN covid_portfolio_project..covid_vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, ROUND(((vaccination_rolling_count / population) * 100), 4) AS rolling_vaccination_percentage
FROM #vaccination_rolling_count
ORDER BY location, date



-- Creating views to store data for visualisations

CREATE VIEW vaccination_rolling_count_view AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS vaccination_rolling_count
FROM covid_portfolio_project..covid_death AS dea
JOIN covid_portfolio_project..covid_vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL