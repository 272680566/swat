package com.swat.controller;

import com.swat.model.Issue;
import com.swat.service.IssueService;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/issues")
public class IssueController {

    private final IssueService issueService;

    public IssueController(IssueService issueService) {
        this.issueService = issueService;
    }

    @GetMapping
    public Map<String, Object> list(
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(required = false, defaultValue = "") String status,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "10") int pageSize) {
        return issueService.list(keyword, status, page, pageSize);
    }

    @GetMapping("/{id}")
    public Object getById(@PathVariable Long id) {
        Issue issue = issueService.getById(id);
        if (issue == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "问题不存在");
            return err;
        }
        return issue;
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Issue issue) {
        return issueService.create(issue);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Long id, @RequestBody Issue issue) {
        return issueService.update(id, issue);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Long id) {
        return issueService.delete(id);
    }
}
