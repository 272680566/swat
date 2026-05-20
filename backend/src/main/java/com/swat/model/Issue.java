package com.swat.model;

public class Issue {

    private Long id;
    private String issueNo;
    private String occurTime;
    private String customerName;
    private String description;
    private String kernelVersion;
    private String status;
    // Basic info
    private String category;
    private Boolean keySite;
    private String siteType;
    private String mgmtDeploy;
    private String kernelDeploy;
    private String rl;
    private String opsTicket;
    private String ecareTicket;
    // Quick properties
    private Boolean bizInterrupt;
    private Boolean urgentRecover;
    private String remark;
    // Discovery
    private Boolean hasAlarm;
    private Boolean alarmTrigger;
    private String findRemark;
    // Timeline
    private String perceiveTime;
    private String createTime;
    private String swatStartTime;
    private String boundTime;
    private String bizRecoverTime;
    private String fullRecoverTime;
    private String timeRemark;
    // Archive
    private String docLink;
    private String screenLink;
    // Emergency plan
    private Boolean hadPlan;
    private Boolean hasPlan;
    private String planName;
    // Audit
    private java.time.LocalDateTime createdAt;
    private String handleDate;
    private java.time.LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getIssueNo() { return issueNo; }
    public void setIssueNo(String issueNo) { this.issueNo = issueNo; }
    public String getOccurTime() { return occurTime; }
    public void setOccurTime(String occurTime) { this.occurTime = occurTime; }
    public String getHandleDate() { return handleDate; }
    public void setHandleDate(String handleDate) { this.handleDate = handleDate; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getKernelVersion() { return kernelVersion; }
    public void setKernelVersion(String kernelVersion) { this.kernelVersion = kernelVersion; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public Boolean getKeySite() { return keySite; }
    public void setKeySite(Boolean keySite) { this.keySite = keySite; }
    public String getSiteType() { return siteType; }
    public void setSiteType(String siteType) { this.siteType = siteType; }
    public String getMgmtDeploy() { return mgmtDeploy; }
    public void setMgmtDeploy(String mgmtDeploy) { this.mgmtDeploy = mgmtDeploy; }
    public String getKernelDeploy() { return kernelDeploy; }
    public void setKernelDeploy(String kernelDeploy) { this.kernelDeploy = kernelDeploy; }
    public String getRl() { return rl; }
    public void setRl(String rl) { this.rl = rl; }
    public String getOpsTicket() { return opsTicket; }
    public void setOpsTicket(String opsTicket) { this.opsTicket = opsTicket; }
    public String getEcareTicket() { return ecareTicket; }
    public void setEcareTicket(String ecareTicket) { this.ecareTicket = ecareTicket; }
    public Boolean getBizInterrupt() { return bizInterrupt; }
    public void setBizInterrupt(Boolean bizInterrupt) { this.bizInterrupt = bizInterrupt; }
    public Boolean getUrgentRecover() { return urgentRecover; }
    public void setUrgentRecover(Boolean urgentRecover) { this.urgentRecover = urgentRecover; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public Boolean getHasAlarm() { return hasAlarm; }
    public void setHasAlarm(Boolean hasAlarm) { this.hasAlarm = hasAlarm; }
    public Boolean getAlarmTrigger() { return alarmTrigger; }
    public void setAlarmTrigger(Boolean alarmTrigger) { this.alarmTrigger = alarmTrigger; }
    public String getFindRemark() { return findRemark; }
    public void setFindRemark(String findRemark) { this.findRemark = findRemark; }
    public String getPerceiveTime() { return perceiveTime; }
    public void setPerceiveTime(String perceiveTime) { this.perceiveTime = perceiveTime; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
    public String getSwatStartTime() { return swatStartTime; }
    public void setSwatStartTime(String swatStartTime) { this.swatStartTime = swatStartTime; }
    public String getBoundTime() { return boundTime; }
    public void setBoundTime(String boundTime) { this.boundTime = boundTime; }
    public String getBizRecoverTime() { return bizRecoverTime; }
    public void setBizRecoverTime(String bizRecoverTime) { this.bizRecoverTime = bizRecoverTime; }
    public String getFullRecoverTime() { return fullRecoverTime; }
    public void setFullRecoverTime(String fullRecoverTime) { this.fullRecoverTime = fullRecoverTime; }
    public String getTimeRemark() { return timeRemark; }
    public void setTimeRemark(String timeRemark) { this.timeRemark = timeRemark; }
    public String getDocLink() { return docLink; }
    public void setDocLink(String docLink) { this.docLink = docLink; }
    public String getScreenLink() { return screenLink; }
    public void setScreenLink(String screenLink) { this.screenLink = screenLink; }
    public Boolean getHadPlan() { return hadPlan; }
    public void setHadPlan(Boolean hadPlan) { this.hadPlan = hadPlan; }
    public Boolean getHasPlan() { return hasPlan; }
    public void setHasPlan(Boolean hasPlan) { this.hasPlan = hasPlan; }
    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }
    public java.time.LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.LocalDateTime createdAt) { this.createdAt = createdAt; }
    public java.time.LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.time.LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
