SELECT * 
FROM dbo.CovidVaccination$
ORDER BY 3,4

--SELECT * 
--FROM dbo.CovidDeaths$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--**Total Case VS Total Deaths**
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100  AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%australia%'
AND continent is not null

--**Total Case VS Population**
SELECT location, date, total_cases, population, (total_deaths/population)*100  AS PercentPopulation
FROM dbo.CovidDeaths
--WHERE location like '%australia%'
WHERE continent is not null

--**Highest infection rate**
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100  AS PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like '%australia%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--**Highest Death rate/ Population**
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount  
FROM dbo.CovidDeaths
--WHERE location like '%australia%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--** Death rate highest in Continent**
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount  
FROM dbo.CovidDeaths
--WHERE location like '%australia%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--** Global Numbers**
SELECT SUM(new_cases) AS TotalCAses, SUM(CAST(total_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null

--JOING BOTH THE DATASHEETS--
SELECT *
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vca
	ON dea.location = vca.location
	AND dea.date = vca.date

--**Total population VS vaccination**--
SELECT dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations, SUM(CONVERT(DECIMAL(10,2), vca.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vca
	ON dea.location = vca.location
	AND dea.date = vca.date
--WHERE dea.continent LIKE '%AUSTRALIA%'
WHERE dea.continent is not null
ORDER BY 2,3 

--USE CTE--

WITH popvsvac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations, SUM(CONVERT(INT, vca.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vca
	ON dea.location = vca.location
	AND dea.date = vca.date
--WHERE dea.continent LIKE '%AUSTRALIA%'
WHERE dea.continent is not null
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac

--TEMP TABLE--

DROP TABLE IF exists  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations, SUM(CONVERT(DECIMAL(10,2), vca.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vca
	ON dea.location = vca.location
	AND dea.date = vca.date
--ERE dea.continent is not null
--ORDER BY 2,3 

SELECT * FROM #PercentPopulationVaccinated

--**CREATE VIEW**--

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations, SUM(CONVERT(DECIMAL(10,2), vca.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vca
	ON dea.location = vca.location
	AND dea.date = vca.date
WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated