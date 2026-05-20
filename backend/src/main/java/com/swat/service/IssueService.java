package com.swat.service;

import com.swat.mapper.IssueMapper;
import com.swat.model.Issue;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class IssueService {

    private final IssueMapper issueMapper;

    public IssueService(IssueMapper issueMapper) {
        this.issueMapper = issueMapper;
    }

    public Map<String, Object> list(String keyword, String status, int page, int pageSize) {
        Map<String, Object> result = new HashMap<>();
        int total = issueMapper.countFiltered(keyword, status);
        int offset = (page - 1) * pageSize;
        result.put("list", issueMapper.findAll(keyword, status, offset, pageSize));
        result.put("total", total);
        result.put("page", page);
        result.put("pageSize", pageSize);
        return result;
    }

    public Issue getById(Long id) {
        return issueMapper.findById(id);
    }

    public Map<String, Object> create(Issue issue) {
        Map<String, Object> result = new HashMap<>();

        String occurDate = issue.getOccurTime();
        if (occurDate == null || occurDate.trim().isEmpty()) {
            occurDate = issue.getHandleDate();
            issue.setOccurTime(occurDate);
        }
        if (occurDate == null || occurDate.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "日期不能为空");
            return result;
        }

        String dateStr = occurDate.substring(0, 10).replace("-", "");
        int count = issueMapper.countByDate(occurDate.substring(0, 10));
        int maxRetries = 5;

        for (int retry = 0; retry < maxRetries; retry++) {
            String issueNo = String.format("SWAT-%s-%03d", dateStr, count + 1 + retry);
            issue.setIssueNo(issueNo);
            try {
                issueMapper.insert(issue);
                result.put("success", true);
                result.put("message", "创建成功");
                result.put("data", issue);
                return result;
            } catch (org.springframework.dao.DuplicateKeyException e) {
                // Retry with next sequence number
            }
        }

        result.put("success", false);
        result.put("message", "创建失败，请重试");
        return result;
    }

    public Map<String, Object> update(Long id, Issue issue) {
        Map<String, Object> result = new HashMap<>();

        Issue existing = issueMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "问题不存在");
            return result;
        }

        // Merge: only overwrite non-null fields from incoming
        if (issue.getOccurTime() != null) existing.setOccurTime(issue.getOccurTime());
        if (issue.getHandleDate() != null) existing.setHandleDate(issue.getHandleDate());
        if (issue.getCustomerName() != null) existing.setCustomerName(issue.getCustomerName());
        if (issue.getDescription() != null) existing.setDescription(issue.getDescription());
        if (issue.getKernelVersion() != null) existing.setKernelVersion(issue.getKernelVersion());
        if (issue.getStatus() != null) existing.setStatus(issue.getStatus());
        if (issue.getCategory() != null) existing.setCategory(issue.getCategory());
        if (issue.getKeySite() != null) existing.setKeySite(issue.getKeySite());
        if (issue.getSiteType() != null) existing.setSiteType(issue.getSiteType());
        if (issue.getMgmtDeploy() != null) existing.setMgmtDeploy(issue.getMgmtDeploy());
        if (issue.getKernelDeploy() != null) existing.setKernelDeploy(issue.getKernelDeploy());
        if (issue.getRl() != null) existing.setRl(issue.getRl());
        if (issue.getOpsTicket() != null) existing.setOpsTicket(issue.getOpsTicket());
        if (issue.getEcareTicket() != null) existing.setEcareTicket(issue.getEcareTicket());
        if (issue.getBizInterrupt() != null) existing.setBizInterrupt(issue.getBizInterrupt());
        if (issue.getUrgentRecover() != null) existing.setUrgentRecover(issue.getUrgentRecover());
        if (issue.getRemark() != null) existing.setRemark(issue.getRemark());
        if (issue.getHasAlarm() != null) existing.setHasAlarm(issue.getHasAlarm());
        if (issue.getAlarmTrigger() != null) existing.setAlarmTrigger(issue.getAlarmTrigger());
        if (issue.getFindRemark() != null) existing.setFindRemark(issue.getFindRemark());
        if (issue.getPerceiveTime() != null) existing.setPerceiveTime(issue.getPerceiveTime());
        if (issue.getCreateTime() != null) existing.setCreateTime(issue.getCreateTime());
        if (issue.getSwatStartTime() != null) existing.setSwatStartTime(issue.getSwatStartTime());
        if (issue.getBoundTime() != null) existing.setBoundTime(issue.getBoundTime());
        if (issue.getBizRecoverTime() != null) existing.setBizRecoverTime(issue.getBizRecoverTime());
        if (issue.getFullRecoverTime() != null) existing.setFullRecoverTime(issue.getFullRecoverTime());
        if (issue.getTimeRemark() != null) existing.setTimeRemark(issue.getTimeRemark());
        if (issue.getDocLink() != null) existing.setDocLink(issue.getDocLink());
        if (issue.getScreenLink() != null) existing.setScreenLink(issue.getScreenLink());
        if (issue.getHadPlan() != null) existing.setHadPlan(issue.getHadPlan());
        if (issue.getHasPlan() != null) existing.setHasPlan(issue.getHasPlan());
        if (issue.getPlanName() != null) existing.setPlanName(issue.getPlanName());

        issueMapper.update(existing);

        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    public Map<String, Object> delete(Long id) {
        Map<String, Object> result = new HashMap<>();

        Issue existing = issueMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "问题不存在");
            return result;
        }

        issueMapper.deleteById(id);
        result.put("success", true);
        result.put("message", "删除成功");
        return result;
    }
}
