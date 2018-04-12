/*************************************************************/
/**		Project: Hospice Carepoint							**/
/**		Author: Mark Burghart (mark.burghart@mediware.com)	**/
/**		Date: 2018-04-03									**/
/**		Description: Extract patient vitals					**/
/*************************************************************/ 

/** 
This SQL Server script extracts visit-level vital results for each person seen by hospice providers after May 2017 to April 2018.
 
Vitals include:
	- temperature
	- Pulse
	- Pain
	- Weight
	- Systolic (as Systolic and Diastolic)
	- Additional BP (SystolicL and DiastolicL)
	- additional pulse (PulseRadial)

There is significant missing data, as well as messy structured data and will require some significant working for modeling purposes.

**/

select a.AdmissionKey
	,p.PatientKey
	,a.StartOfCare
	,a.DischargeDate
	,lct.ClinicType
	,pv.fPatientTaskKey as patienttaskkey
	,pv.VisitDate
	,pv.temperature as Temperature
	,pv.Pulse
	,pv.Pain
	,pv.Resp
	,pv.Weight
	,pv.Systolic
	,pv.Diastolic
	,pv.PulseRadial
	,pv.SystolicL
	,pv.DiastolicL
from [staging].[dbo].[Episode] as e
inner join staging.dbo.Admission as a
	on a.admissionkey = e.fAdmissionKey
inner join staging.dbo.patient as p
	on a.fPatientKey = p.PatientKey
inner join staging.dbo.clinic as c
	on c.flistclinicstatuskey != 2 
		and p.fClinicKey = c.ClinicKey
inner join staging.dbo.ListClinicType as lct
	on c.fListClinicTypeKey = lct.ClinicTypeRoleKey
inner join staging.dbo.PatientTask as pt
	on e.EpisodeKey = pt.fEpisodeKey
left outer join staging.dbo.PatientVitalSign as pv
	on pt.patienttaskkey = pv.fpatienttaskkey
where lct.ClinicType = 'Hospice' 
	AND a.DischargeDate <= '12/31/2017'
	AND a.StartOfCare >= '1/1/2016'
	AND pv.VisitDate > '5/1/2017'
	AND pv.VisitDate < '4/1/2018' --pull out results after 5/1/17, when ESAS release occurred
order by pv.VisitDate
;

--only returns 45 results and most are nulls. Will remove right now...

