package com.swat.controller;

import com.swat.model.Site;
import com.swat.service.SiteService;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sites")
public class SiteController {

    private final SiteService siteService;

    public SiteController(SiteService siteService) {
        this.siteService = siteService;
    }

    @GetMapping
    public Map<String, Object> list(
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "10") int pageSize) {
        return siteService.list(keyword, page, pageSize);
    }

    @GetMapping("/all")
    public List<Site> listAll() {
        return siteService.listAll();
    }

    @GetMapping("/{id}")
    public Object getById(@PathVariable Long id) {
        Site site = siteService.getById(id);
        if (site == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "局点不存在");
            return err;
        }
        return site;
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Site site) {
        if (site.getName() == null || site.getName().trim().isEmpty()) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "局点名称不能为空");
            return err;
        }
        site.setName(site.getName().trim());
        return siteService.create(site);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Long id, @RequestBody Site site) {
        return siteService.update(id, site);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Long id) {
        return siteService.delete(id);
    }

    @GetMapping("/check-name")
    public Map<String, Object> checkName(@RequestParam String name) {
        if (name == null || name.trim().isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("exists", false);
            return result;
        }
        return siteService.checkName(name.trim());
    }
}
