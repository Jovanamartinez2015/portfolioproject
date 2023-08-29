select *
from [Protfolio ].[dbo].['covid dead $']
order by 3,4

--select *
--from [Protfolio ].[dbo].['covid vac$']
--order by 3,4


Select location, date , total_cases , new_cases , total_deaths , population 
from [Protfolio ].[dbo].['covid dead $']
order by 1, 2

--Looking at total cases vs total deaths

Select location, date , total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [Protfolio ].[dbo].['covid dead $']
order by 1, 2


Select location, date , total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
from [Protfolio ].[dbo].['covid dead $']
where location like '%state%'
order by 1, 2





Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Protfolio ].[dbo].['covid dead $']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Protfolio ].[dbo].['covid dead $']
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Protfolio ].[dbo].['covid dead $']
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Protfolio ].[dbo].['covid dead $']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Protfolio ].[dbo].['covid dead $'] dea
Join [Protfolio ].[dbo].['covid vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Protfolio ].[dbo].['covid dead $'] dea
Join [Protfolio ].[dbo].['covid vac$']  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

	DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  [Protfolio ].[dbo].['covid dead $']dea
Join [Protfolio ].[dbo].['covid vac$']  vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Protfolio ].[dbo].['covid dead $']dea
Join [Protfolio ].[dbo].['covid vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated
	

