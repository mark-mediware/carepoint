/*************************************************************/
/**		Project: Hospice Carepoint							**/
/**		Author: Mark Burghart (mark.burghart@mediware.com)	**/
/**		Date: 2018-04-03									**/
/**		Description: Load patient ESAS results				**/
/*************************************************************/ 

/** 
This SQL Server script extracts visit-level ESAS results for each person seen by hospice providers between
2016 and 2018. ESAS results may only be present after a release occurred on May 1, 2017. 

If so, I will need toadjust my model population to account for this, as ESAS results will factor heavily into coefficients.
(which can be done in Python)
**/


SELECT PEM.fpatientkey as patientkey 
	,a.admissionkey, 
	,a.StartOfCare, 
	,a.DischargeDate,
	,pem.fPatientTaskKey as patienttaskkey, 
	,le.ESASName, 
	,pem.ESASValue, 
	,pem.TaskTargetDate, 
	,pem.VisitDate
FROM [Staging].[dbo].[PatientESASMeasure] PEM
    inner join staging.dbo.patienttask pt on pt.patienttaskkey = pem.fpatienttaskkey
	inner join staging.dbo.patient p on p.patientkey = pem.fpatientkey
	inner join staging.dbo.clinic c on c.flistclinicstatuskey <> 2 and c.clinickey = p.fclinickey -- <> is !=
    inner join staging.dbo.ListESASName le on le.listesasnamekey = pem.flistesasnamekey
    inner join staging.dbo.episode e on e.StartofCareDate >= '5/1/2017' and e.episodekey = pt.fepisodekey
    inner join staging.dbo.Admission a on a.admissionkey = e.fadmissionkey
	inner join staging.dbo.ListClinicType as lct on c.fListClinicTypeKey = lct.ClinicTypeRoleKey
where lct.ClinicType = 'Hospice' 
	AND pem.VisitDate >= '5/1/2017' 
order by a.startofcare, pem.fPatientKey, pem.fPatientTaskKey, le.ESASName
;