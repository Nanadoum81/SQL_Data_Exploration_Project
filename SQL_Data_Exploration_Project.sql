Select *
From SQL_Data_Exploration_Project..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From SQL_Data_Exploration_Project..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From SQL_Data_Exploration_Project..CovidDeaths$
Where continent is not null
order by 1,2

--Look at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as PercentPopulationInfected
From SQL_Data_Exploration_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM SQL_Data_Exploration_Project..CovidDeaths$
--Where location like '%states%'
group by location, Population
order by PercentPopulationInfected desc

---Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQL_Data_Exploration_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing the continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQL_Data_Exploration_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQL_Data_Exploration_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Data_Exploration_Project..CovidDeaths$ dea
Join SQL_Data_Exploration_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3
	)
	
	--USE CTE

	With PopvsVac(Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Data_Exploration_Project..CovidDeaths$ dea
Join SQL_Data_Exploration_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
	)
	Select * , (RollingPeopleVaccinated/Population)*100
	From PopvsVac


	--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent  nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric,
	)
Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Data_Exploration_Project..CovidDeaths$ dea
Join SQL_Data_Exploration_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
	
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Data_Exploration_Project..CovidDeaths$ dea
Join SQL_Data_Exploration_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
