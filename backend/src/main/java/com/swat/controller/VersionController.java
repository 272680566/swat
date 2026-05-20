package com.swat.controller;

import com.swat.model.Version;
import com.swat.service.VersionService;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/versions")
public class VersionController {

    private final VersionService versionService;

    public VersionController(VersionService versionService) {
        this.versionService = versionService;
    }

    @GetMapping
    public Object list() {
        return versionService.list();
    }

    @GetMapping("/{id}")
    public Object getById(@PathVariable Long id) {
        Version ver = versionService.getById(id);
        if (ver == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "版本不存在");
            return err;
        }
        return ver;
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Version version) {
        if (version.getVersionCode() == null || version.getVersionCode().trim().isEmpty()) {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "版本号不能为空");
            return err;
        }
        version.setVersionCode(version.getVersionCode().trim());
        return versionService.create(version);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Long id, @RequestBody Version version) {
        return versionService.update(id, version);
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Long id) {
        return versionService.delete(id);
    }

    @GetMapping("/check-code")
    public Map<String, Object> checkCode(@RequestParam String code) {
        if (code == null || code.trim().isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("exists", false);
            return result;
        }
        return versionService.checkVersionCode(code.trim());
    }
}
