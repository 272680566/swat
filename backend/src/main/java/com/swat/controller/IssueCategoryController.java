package com.swat.controller;

import com.swat.model.IssueCategory;
import com.swat.service.IssueCategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/issue-categories")
public class IssueCategoryController {

    private final IssueCategoryService service;

    public IssueCategoryController(IssueCategoryService service) {
        this.service = service;
    }

    @GetMapping("/tree")
    public Object tree() {
        return service.tree();
    }

    @GetMapping
    public Object list() {
        return service.list();
    }

    @GetMapping("/{id}")
    public Object getById(@PathVariable Long id) {
        IssueCategory cat = service.getById(id);
        if (cat == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "分类不存在");
            return err;
        }
        return cat;
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody IssueCategory cat) {
        return service.create(cat);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Long id, @RequestBody IssueCategory cat) {
        return service.update(id, cat);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Long id) {
        return service.delete(id);
    }
}
