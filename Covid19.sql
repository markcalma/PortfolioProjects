select * from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..covidvaccination
--order by 3,4


-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location = 'Philippines'
where continent is not null
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is not null
group by location
order by TotalDeathCount desc


-- let's break things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is null
group by location
order by TotalDeathCount desc

-- let's break things down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  --total_deaths, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location = 'Philippines'
where continent is not null
--group by date
order by DeathPercentage desc


-- looking at total population vs vaccination

-- use cte

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vaccinated_percentage
from PopvsVac
order by Rolling_People_Vaccinated_percentage desc


-- temp table

DROP Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vaccinated_percentage
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3