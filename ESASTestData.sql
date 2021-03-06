SELECT PEM.fpatientkey as patientkey, 
	a.admissionkey, 
	a.StartOfCare, 
	a.DischargeDate,
	pem.fPatientTaskKey as patienttaskkey, 
	le.ESASName, 
	pem.ESASValue, 
	pem.TaskTargetDate, 
	pem.VisitDate, 
	dct.DischargeType,
	dcs.DischargeStatusDescription,
	icd10.DiagnosisCode as TerminalDiagnosis,
	icd10.ICD10CodeShortDesc, -- able to find a larger grouping or cluster?
	lr.ReferralType,
	llc.LevelofCare
FROM [Staging].[dbo].[PatientESASMeasure] PEM
    inner join patienttask pt on pt.patienttaskkey = pem.fpatienttaskkey
	inner join patient p on p.patientkey = pem.fpatientkey
	inner join clinic c on c.flistclinicstatuskey <> 2 and c.clinickey = p.fclinickey -- <> is !=
    inner join ListESASName le on le.listesasnamekey = pem.flistesasnamekey
    inner join episode e on e.StartofCareDate >= '5/1/2017' and e.episodekey = pt.fepisodekey
    inner join Admission a on a.admissionkey = e.fadmissionkey
    --left outer join LevelOfCare loc on loc.fadmissionkey = a.admissionkey and pem.visitdate between loc.startdate and loc.enddate and loc.active = 1
    left outer join AdmissionReferralSource ref on ref.fAdmissionKey = a.AdmissionKey
    left outer join ListReferralType lr on lr.ListReferralTypeKey = ref.flistreferraltypekey
    left outer join AdmissionDiagnosisICD10 icd on icd.fAdmissionKey = a.AdmissionKey and icd.fListDiagnosisTypeKey = 1
    left outer join ListDischargeStatus dcs on dcs.DischargeStatusCode = a.fDischargeStatusCode 
	left outer join ListDischargeType dct on dct.ListDischargeTypeKey = a.fListDischargeTypeKey
    outer apply
        (
            select top 1 * 
            from levelofcare l 
            where l.fadmissionkey = a.admissionkey and pem.visitdate between l.startdate and l.enddate and l.active = 1 
            order by l.enddate desc
        ) loc
    left outer join ListLevelofCare llc on llc.listlevelofcarekey = loc.flistlevelofcarekey
    Outer apply
        (
        Select c.DiagnosisCode, c.ICD10CodeShortDesc
        from ListICD10DiagnosisCode c
        where c.ListICD10DiagnosisCodeKey = fListICD10DiagnosisCodeKey
        ) icd10
where pem.VisitDate >= '5/1/2017'

order by a.startofcare, pem.fPatientKey, pem.fPatientTaskKey, le.ESASName


--How is Brad controlling for death via Hospice?

--dbo.AdmissionHospice represents all hospice admissions, right?
-- 	-- AdmissionHospice seems to pull from Admissions table anyway...