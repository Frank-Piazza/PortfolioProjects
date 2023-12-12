select * from CovidDeaths
order by 3,4


select * from CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS PercentageDeaths
From PortfolioProject1.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs population
-- Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population) * 100 AS PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at countries with Highest Infection Rate vs Population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
-- where location like '%states%'
group by location, population
Order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Rate per Population
Select location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths
-- where location like '%states%'
WHERE continent IS NOT NULL
group by location
Order by TotalDeathCount DESC

-- BREAK DOWN BY CONTINENT (Death Count)
-- Showing Continents with the Highest Death Count per Population
Select location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths
-- where location like '%states%'
WHERE continent IS NULL -- Continent name is in location!
group by location
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS
-- For Each date
Select date, 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
-- where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
Order by 1,2

--For all dates (Result is 1 row) 
Select --date, 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
-- where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, /* (new vaccinations per day) */
	SUM(CAST(vac.new_vaccinations AS INT)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
INNER JOIN
PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Creating a VIEW
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, /* (new vaccinations per day) */
	SUM(CAST(vac.new_vaccinations AS INT)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
INNER JOIN
PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentagePopulationVaccinated