Select *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases Vs Total Deaths

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS '% of Deaths'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Venezuela%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases Vs Population
SELECT location, date, total_cases,population, (total_cases/population)*100 AS '% of Population with covid'
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Venezuela%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS '% of Population with covid'
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Venezuela%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Showing countries with Highest Death Count per Population at countries with highest infection rate compared to Population
SELECT location,population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS '% of Population dead'
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%SOUTH%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC


--Looking by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers 
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths , (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Venezuela%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT * 
FROM PortfolioProject..CovidVaccinations


-- Looking at Total Population Vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(ISNULL(CONVERT(BIGINT,v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS Accumulated_Vaccination,
--(Accumulated_Vaccination/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Accumulated_Vaccination)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(ISNULL(CONVERT(BIGINT,v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS Accumulated_Vaccination
--(Accumulated_Vaccination/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (Accumulated_Vaccination/Population)*100
FROM PopvsVac



--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Accumulated_Vaccination numeric
)

INSERT INTO  #PercentPopulationVaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(ISNULL(CONVERT(BIGINT,v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS Accumulated_Vaccination
--(Accumulated_Vaccination/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
--WHERE d.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (Accumulated_Vaccination/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to sotre date for later visualization

USE PortfolioProject
CREATE VIEW PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(ISNULL(CONVERT(BIGINT,v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS Accumulated_Vaccination
--(Accumulated_Vaccination/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated 