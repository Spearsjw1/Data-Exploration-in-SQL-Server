/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations

--ORDER BY 3,4

SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Total cases vs. total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--population vs. total cases
SELECT Location, date, total_cases, population, (total_cases / population)*100 AS infection_rate
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

SELECT Location, MAX(total_cases) as peak_case_count, population, MAX((total_cases / population))*100 AS infection_rate
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY population, location
ORDER BY infection_rate DESC

--Highest death ratio by country

SELECT Location, MAX(cast(total_deaths AS int)) AS death_rate
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY population, location
ORDER BY death_rate DESC

--Max total deaths by continent 
SELECT continent, MAX(cast(total_deaths AS int)) AS death_rate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY death_rate DESC

--Global death percent

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) AS global_death_percent
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


--Total vaccinations across world.
WITH populationvsVaccinations (continent, location, date, population, new_vaccinations, count_vac_by_country)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS count_vac_by_country
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT *, (count_vac_by_country/population)*100 as percent_vac_by_country
FROM populationvsVaccinations
ORDER BY 2,3

--Views for visualization

--Vaccination Percent
CREATE VIEW PercentVaccinated AS
WITH populationvsVaccinations (continent, location, date, population, new_vaccinations, count_vac_by_country)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS count_vac_by_country
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
--Global Death Rate

CREATE VIEW GlobalDeathRate as
(
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) AS global_death_percent
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2
)

--Queries for tableau visualizations

--Table1
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Table 2
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Table 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Table4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

--Table5
--Total vaccinations across world.
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
