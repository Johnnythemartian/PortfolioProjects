
select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at total cases vs total deaths
--shows likelihood of death if contract COVID in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs. Population
--Shows what percentage of population got COVID
Select Location, date, total_cases, Population, (total_cases/Population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as InfectionMAXPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by InfectionMAXPercentage desc

--Shows countries with highest death rate
Select Location, MAX(cast(total_deaths as bigint)) as totaldeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location
order by totaldeathcount desc


--Break things down by Continent

Select Location, MAX(cast(total_deaths as bigint)) as totaldeathCount
From PortfolioProject..CovidDeaths
Where continent is null
--Where location like '%states%'
Group by Location
order by totaldeathcount desc

--showing continents with highest death count

Select continent, MAX(cast(total_deaths as bigint)) as totaldeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by totaldeathcount desc



--Global Numbers per day

Select date, SUM(new_cases) as total_daily_cases, SUM(cast(new_deaths as bigint)) as total_daily_deaths, SUM(cast(new_deaths as bigint))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
order by 1,2

--Global Total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--looking at rolling increase in vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


With PopvsVac (Continent, location, date, population, new_vaccination, RollingVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVacc/Population)*100 as RollingVaccPercent
From PopvsVac


-- Temp Table

DROP Table if exists #percentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVacc numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingVacc/Population)*100 as RollingVaccPercent
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *
From PercentPopulationVaccinated