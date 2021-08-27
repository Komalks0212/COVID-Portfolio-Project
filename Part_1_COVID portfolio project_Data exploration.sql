SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Death percentage compared to total case
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Death percentage compared to total case in Africa
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Africa%'
ORDER BY 1,2

-- Total cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Population in India
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

-- Total Infection percentage per country
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as HighestPercentagePopulationAffected
FROM PortfolioProject..CovidDeaths
Group by Population, Location
ORDER BY HighestPercentagePopulationAffected DESC

-- Total Infection percentage per country
SELECT Location, MAX(total_deaths) as HighestDeathCount, population, MAX((total_deaths/population))*100 as HighestPercentagePopulationDeath
FROM PortfolioProject..CovidDeaths
Group by Population, Location
ORDER BY HighestPercentagePopulationDeath DESC

--Total death count
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by Location
Order by TotalDeathCount DESC

--Total death count per continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
Group by location
Order by TotalDeathCount DESC

-- Showing highest death counts in every continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
Order by TotalDeathCount DESC

--Queries for Global numbers

--Total cases per day

SELECT date, SUM(new_cases) as TotalCases
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
Order by 1

--Total cases and deaths per day

SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
Order by 1

-- Daily death percentage

SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
Order by 1

--Total deaths vs total cases

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1

--Total Deaths vs Total Population

SELECT SUM(population) as TotalPopulation, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(population))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM PortfolioProject..CovidVaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date


-- Total Population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * FROM PopvsVac

-- Using CTE for calculating vaccinated percentage

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage 
FROM PopvsVac



-- Creating a table with above data

DROP TABLE if exists #PercentPopulationVaccinated 

CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255), 
Location varchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage 
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

DROP VIEW if exists PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated
