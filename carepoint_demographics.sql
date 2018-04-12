/*************************************************************/
/**		Project: Hospice Carepoint							**/
/**		Author: Mark Burghart (mark.burghart@mediware.com)	**/
/**		Date: 2018-04-03									**/
/**		Description: ETL patient demographics				**/
/**		Database: KSI Staging 								**/
/*************************************************************/ 

/** 
This SQL Server script extracts patient demographics for each person seen by hospice providers between
may 2017 and april 2018.  

If so, I will need toadjust my model population to account for this, as ESAS results will factor heavily into coefficients.
(which can be done in Python)
**/

select 
	tmp.AdmissionKey
	,tmp.PatientKey
	,p.ZIPCode
	,tmp.StartOfCare
	,tmp.DischargeDate
	,tmp.patienttaskkey
	,p.gender
	,p.DateofBirth
	,ldt.DischargeType
	,lds.DischargeStatusDescription as DischargeStatus
	,his.DischargeReason
	,lad.AdvanceDirective
	,icd10.DiagnosisCode as TerminalDiagnosis
	,icd10.DiagnosisDesc
	,lr.ReferralType
	,llc.LevelofCare
	,race.Race
	,lit.InsuranceType
from (
	SELECT PEM.fpatientkey as patientkey 
		,a.admissionkey 
		,a.StartOfCare 
		,a.DischargeDate
		,pem.fPatientTaskKey as patienttaskkey 
		,le.ESASName 
		,pem.ESASValue 
		,pem.TaskTargetDate		
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
) as tmp
inner join staging.dbo.Admission as a
	on a.admissionkey = tmp.AdmissionKey
left outer join staging.dbo.patient as p
	on tmp.patientkey = p.PatientKey
left outer join staging.dbo.PatientAdvanceDirective as pad
	on p.PatientKey = pad.fPatientKey
left outer join staging.dbo.ListDischargeType as ldt
	on a.fListDischargeTypeKey = ldt.ListDischargeTypeKey
left outer join staging.dbo.ListDischargeStatus as lds
	on a.fDischargeStatusCode = lds.DischargeStatusCode
left outer join staging.dbo.ListHISDischargeReason as his
	on a.fListHISDischargeReasonKey = his.ListHISDischargeReasonKey
left outer join  staging.dbo.ListAdvanceDirective as lad
	on pad.fListAdvanceDirectiveKey = lad.ListAdvanceDirectiveKey
left outer join staging.dbo.AdmissionDiagnosisICD10 as icd 
	on icd.fAdmissionKey = a.AdmissionKey and icd.fListDiagnosisTypeKey = 1
left outer join staging.dbo.ListICD10DiagnosisCode as icd10
	on icd.fListICD10DiagnosisCodeKey = icd10.ListICD10DiagnosisCodeKey
left outer join staging.dbo.AdmissionReferralSource as ref 
	on ref.fAdmissionKey = a.AdmissionKey
left outer join staging.dbo.ListReferralType as lr 
	on lr.ListReferralTypeKey = ref.flistreferraltypekey
outer apply
        (
            select top 1 * 
            from staging.dbo.levelofcare as l 
            where l.fadmissionkey = a.admissionkey and l.active = 1 
            order by l.enddate desc
        ) as loc
left outer join staging.dbo.ListLevelofCare as llc 
	on llc.listlevelofcarekey = loc.flistlevelofcarekey
left outer join staging.dbo.PatientRace as pr
	on p.PatientKey = pr.fPatientKey
left outer join staging.dbo.ListRace as race
	on pr.fListRaceKey = race.ListRaceKey
left outer join staging.dbo.PatientInsurance as pins
	on p.PatientKey = pins.fPatientKey
left outer join staging.dbo.Insurance as ins
	on pins.fInsuranceKey = ins.InsuranceKey
left outer join staging.dbo.ListInsuranceType as lit
	on ins.fListInsuranceTypeKey = lit.ListInsuranceTypeKey


;
