/*************************************************************/
/**		Project: Hospice Carepoint							**/
/**		Author: Mark Burghart (mark.burghart@mediware.com)	**/
/**		Date: 2018-03-27									**/
/**		Description: NHPCO analysis data pull 				**/
/*************************************************************/ 

-- This T-SQL script pulls the population of individuals with Hospice admission and outcome for 
-- exploratory analysis, survival analysis and modeling to present internally at Mediware,
-- but also externally at the April 2018 NHPCO conference. 
-- Actual analysis will be performed in other R/Python scripts.





select 
	distinct a.AdmissionKey
	,p.PatientKey
	,p.ZIPCode
	,a.StartOfCare
	,a.DischargeDate
	,p.gender
	,p.DateofBirth
	,ldt.DischargeType
	,lds.DischargeStatusDescription as DischargeStatus
	,his.DischargeReason
	,lct.ClinicType
	,lad.AdvanceDirective
	,icd10.DiagnosisCode as TerminalDiagnosis
	,icd10.DiagnosisDesc
	,lr.ReferralType
	,llc.LevelofCare
	,race.Race
	,lit.InsuranceType
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
where lct.ClinicType = 'Hospice' 
	AND a.DischargeDate <= '12/31/2017'
	AND a.StartOfCare >= '1/1/2016'
order by p.PatientKey, a.DischargeDate
;




