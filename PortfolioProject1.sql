Select *
From PortfolioProject1..CovidDeaths
Where Continent is not null
Order by 3,4

--Select *
--From PortfolioProject1..Covidvaccinations
--Order by 3,4

--Select the data we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs. Total Deaths
--Shows the likelyhood of dying when contracting Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at countries with highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Showing country with the Highest Death Count per Population

Select location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

Select location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where Continent is null
Group by location
Order by TotalDeathCount desc

-- Showing the continents with the highest death counts per population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases)as total_cases, Sum(cast(new_deaths as int))as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Vaccinations vs Total Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location)
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations )) Over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations )) Over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--Temp Table


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations )) Over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Drop Table if exists #PercentPopulationVaccinated
Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations )) Over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations )) Over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3