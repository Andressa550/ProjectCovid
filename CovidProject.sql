SELECT * FROM CovidProject..CovidDeaths
where continent is not null
ORDER BY 3,4 


--SELECT * FROM CovidProject..CovidVaccinations
--ORDER BY 3,4 

-- SELECT DATA THAT WE ARE GOING TO BE USING 


SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM CovidProject..CovidDeaths
where continent is not null
where location like '%brazil%'
ORDER BY 1,2


-- Looking at total cases vs Population
-- Show what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM CovidProject..CovidDeaths
where continent is not null
where location like '%brazil%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate Compared to Population

SELECT Location, population, max(total_cases) as HighestInfectionCount, max( (total_cases/population)*100) as PercentagePopulationInfected
FROM CovidProject..CovidDeaths
--where location like '%brazil%'
Group By Location, population
where continent is not null
ORDER BY PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, max(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidProject..CovidDeaths
where continent is not null
Group By Location
ORDER BY TotalDeathsCount desc

-- Let's Break things down by continent

-- Showing contintens with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidProject..CovidDeaths
where continent is not null
Group By continent
ORDER BY TotalDeathsCount desc


-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum (cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


--- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over ( partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE
with PopvsVac ( Continent, Locatioon, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over ( partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over ( partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store date for late visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over ( partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*
from PercentPopulationVaccinated



