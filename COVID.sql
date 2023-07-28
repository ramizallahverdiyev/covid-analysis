USE PortfolioProject

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases vs Total Deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathRate
FROM CovidDeaths
WHERE location like '%Azerbaijan%'
and continent is not null
ORDER BY 1,2

--Total Cases vs Population
SELECT location,date,population,total_cases,(total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
Where location like '%Azerbaijan%'
and continent is not null
ORDER BY 1,2

--Countries with highest infection rate compared to population
 SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--Where location like '%Azerbaijan%'
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Countries with highest death count per population
SELECT location,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Total deaths by continent
SELECT location,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--New cases and new deaths by each day
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total Population Vs vaccinations using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS

(SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent IS NOT NULL

)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating view
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated