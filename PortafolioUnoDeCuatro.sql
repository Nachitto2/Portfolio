--Selecciona la tabla CovidDeaths
select *
from JustProject..CovidDeaths
order by 3,4


--Selecciona los datos que vamos a estar utilizando
select location, date, total_cases, new_cases, population
from JustProject..CovidDeaths
order by 1,2


--Mirando a cantidad de infectados vs muertes
--Shows the likelihood of dying if you contract covid in Argentina each day
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from JustProject..CovidDeaths
where location like '%gen%'
order by 1,2	

--Mirando casos totales vs poblacion
select location, date, total_cases, population,(total_cases/population)*100 as InfPercentage
from JustProject..CovidDeaths
where location like '%gen%'
order by 1,2

--Mirando a los paises con mayor porcentaje de muertes
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfPercentage
from JustProject..CovidDeaths
group by location, population
order by InfPercentage desc

--Mirando a los paises con mayor numero de muertes
select location, max(cast(total_deaths as int)) as HighestDeathCount
from JustProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

--Mirando los continentes con mayor numero de muertes	
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from JustProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--global numbers
--Muertes vs Infectados
select  Sum(new_cases) as InfPerDay,sum(cast (new_deaths as int)) as DeathPerDay,
--date,
sum(cast (new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from JustProject..CovidDeaths
--where location like '%gen%'
where continent is not null
--group by date
order by 1,2

--Total Deaths vs Total Infected
select  Sum(new_cases) as InfPerDay,sum(cast (new_deaths as int)) as DeathPerDay,
sum(cast (new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from JustProject..CovidDeaths
--where location like '%gen%'
where continent is not null
order by 1,2

--COVID VACCINATIONS
select *
from JustProject..CovidVaccinations
order by 3,4

--JOIN
--Mirando vacunas vs Poblacion (El campo "Poblacion" Está solamente en la tabla de muertes)
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)/dth.population)*100
from JustProject..CovidDeaths dth
Join JustProject..CovidVaccinations vac
	on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
order by 2,3


--Lo que busco hacer aca es conocer la cantidad y porcentaje de personas vacunadas hay tres maneras
--a) Use CTE
with PopsvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)/dth.population)*100
from JustProject..CovidDeaths dth
Join JustProject..CovidVaccinations vac
	on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac

--b) TEMP Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),	
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)/dth.population)*100
from JustProject..CovidDeaths dth
Join JustProject..CovidVaccinations vac
	on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--c) Sencillamente usando total vaccinations. Los numeros dan distintos porque es un error de la base de datos
select dth.continent, dth.location, dth.date, dth.population, vac.total_vaccinations, (vac.total_vaccinations/population)*100
from JustProject..CovidDeaths dth
Join JustProject..CovidVaccinations vac
	on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null

--creando una vista para guardar data para mas tarde
create view PercentPopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)/dth.population)*100
from JustProject..CovidDeaths dth
Join JustProject..CovidVaccinations vac
	on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null

select * from PercentPopulationVaccinated


