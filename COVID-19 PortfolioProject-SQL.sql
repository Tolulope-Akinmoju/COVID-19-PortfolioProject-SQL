

COVID-19 Data Exploration-SQL

Skills: Joins, CTEs, Aggregate Functions, Creating Views, Converting data type, Temp Tables



*/


SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4



SELECT *
FROM PortfolioProject.dbo.CovidVaccinations$
WHERE continent is not null
ORDER BY 3,4

--For the first part of the project, we would be working with the CovidDeaths$ table

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2



--Analyzing Total Cases Vs Total Deaths
--Examined the likelihood of dying if a person contracts Covid in Nigeria

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like 'N%ria%'
AND continent is not null
ORDER BY 1,2



--Analyzing the Total Cases vs Population
--Shows what percentage of the population contracted Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentageDeath
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like 'N%ria%'
ORDER BY 1,2



--Looking at Countries with the highest infection rate compared to the Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentInfectedPopulation
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
GROUP BY Location, population
ORDER BY PercentInfectedPopulation desc



--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
WHERE continent is not null
GROUP BY Location
ORDER BY HighestDeathCount desc




--Let us examine the difference if we break it down by Continent
--Showing continents with the highest death ount per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--Showing Percentage death daily by countries

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
 WHERE continent is not null
ORDER BY 1,2



--GLOBAL TRENDS

--Showing Percentage death VS population

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 as PercentageDeath
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
 WHERE continent is not null
ORDER BY 1,2



--Looking at Total Population vs Vaccinations
--Percentage of people that have recaived atleast one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
Join PortfolioProject.dbo.CovidVaccinations$ AS vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3


--USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
Join PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingpeopleVaccinated/population)*100 AS PercentpeopleVaccinated
From PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentagePopulationVaccinated 
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
Join PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 
FROM #PercentagePopulationVaccinated





--Creating View for further visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
Join PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3



Create View PercentageDeath AS
SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
 WHERE continent is not null
--ORDER BY 1,2


Create View HighestDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCountContinent
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
WHERE continent is not null
GROUP BY continent
--ORDER BY HighestDeathCount desc


Create View HighestLocationDeathCount AS
SELECT Location, MAX(cast(total_deaths as int)) AS HighestLocationDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
WHERE continent is not null
GROUP BY Location
--ORDER BY HighestDeathCount desc


Create View HighestInfectionCount AS
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like 'N%ria%'
GROUP BY Location, population
--ORDER BY PercentInfectedPopulation desc