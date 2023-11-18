


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `CovidDeaths`
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS GotCovidPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;


-- Looking at countries with highest infection rate compared to population 
SELECT location, population, 
		MAX(total_cases) AS HighestInfectionCount, 
		MAX((total_cases/population)) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
-- WHERE location LIKE '%states%' --
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing countries with highest death count per population
SELECT location, 
	MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%states%' --
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC;


-- Let's Break things down by Continent
SELECT location, 
	MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%states%' --
WHERE continent is NULL
GROUP BY location
ORDER BY 2 DESC;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, 
			SUM(new_deaths) AS total_deaths,
			 SUM(new_deaths) / SUM(new_cases) * 100 AS deathPercentage
FROM CovidDeaths
	WHERE continent is not NULL
	GROUP BY date
ORDER BY 1, 2;

-- GLOBAL NUMBER (All countries combined, for all dates)
SELECT 	    SUM(new_cases) AS total_cases, 
			SUM(new_deaths) AS total_deaths,
			 SUM(new_deaths) / SUM(new_cases) * 100 AS deathPercentage
FROM CovidDeaths
	WHERE continent is not NULL
	--  GROUP BY date
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations (Video:55:02)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
		AND
		dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3


-- Looking at Total Population vs Vaccinations (***Partition by not working***)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as UNSIGNED)) -- CAST because varchar -- 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM  CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
		AND
		dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3	


--  TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



-- Creating VIEW to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as UNSIGNED)) -- CAST because varchar -- 
	OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM  CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
		AND
		dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER by 2,3	



CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.date FROM CovidDeaths dea

SELECT * FROM PercentPopulationVaccinated