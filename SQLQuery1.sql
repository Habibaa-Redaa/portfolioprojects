SELECT * 
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations$
order by 3,4

--select data that we are going to be using
select location , date , total_cases , new_cases , total_deaths , population
from PortfolioProject..CovidDeaths$
order by 1,2

--looking at total_cases vs total_deaths
select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
   and continent is not null
order by 1,2

--looking at total cases vs population
select location , date ,population, total_cases ,  (total_cases/population)*100 as percentagepopulationinfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2


--looking at countries with Highest infection rate compared to population
select location ,population, MAX(total_cases) AS HighestInfectionCount ,MAX((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
GROUP BY location ,population --USING MAX HAVE TO AGGREGATE
order by percentpopulationinfected DESC


--Showing countries with highest death count per population
--cast for null data
select location , MAX(cast(total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP BY location
order by TotalDeathCount DESC


--break things down by continent
select continent , MAX(cast(total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--showing contintents with the highest death count per population
select continent , MAX(cast(total_deaths as int)) AS TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_deaths ,SUM(cast(new_deaths as int ))/SUM(New_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2
------------------------------------------------------------------------
--2nd table

select *
from PortfolioProject..CovidVaccinations$

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using CTE
With popvsvac (continent , location , date , population ,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * , (rollingpeoplevaccinated/population)*100
from popvsvac


-- temp table
DROP TABLE if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
rollingpeoplevaccinated numeric 
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
select * , (rollingpeoplevaccinated/population)*100
FROM #percentpopulationvaccinated



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null

select *
from PercentPopulationVaccinated