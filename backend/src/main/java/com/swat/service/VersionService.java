package com.swat.service;

import com.swat.mapper.SiteMapper;
import com.swat.mapper.VersionMapper;
import com.swat.model.Version;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class VersionService {

    private final VersionMapper versionMapper;
    private final SiteMapper siteMapper;

    public VersionService(VersionMapper versionMapper, SiteMapper siteMapper) {
        this.versionMapper = versionMapper;
        this.siteMapper = siteMapper;
    }

    public List<Version> list() {
        return versionMapper.findAll();
    }

    public Version getById(Long id) {
        return versionMapper.findById(id);
    }

    public Map<String, Object> create(Version version) {
        Map<String, Object> result = new HashMap<>();

        Version existing = versionMapper.findByVersionCode(version.getVersionCode());
        if (existing != null) {
            result.put("success", false);
            result.put("message", "版本号已存在");
            return result;
        }

        try {
            versionMapper.insert(version);
            result.put("success", true);
            result.put("message", "创建成功");
            result.put("data", version);
        } catch (DuplicateKeyException e) {
            result.put("success", false);
            result.put("message", "版本号已存在");
        }
        return result;
    }

    public Map<String, Object> update(Long id, Version version) {
        Map<String, Object> result = new HashMap<>();

        Version existing = versionMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "版本不存在");
            return result;
        }

        // Check version code uniqueness against other records
        if (version.getVersionCode() != null && !version.getVersionCode().equals(existing.getVersionCode())) {
            Version dup = versionMapper.findByVersionCode(version.getVersionCode());
            if (dup != null) {
                result.put("success", false);
                result.put("message", "版本号已存在");
                return result;
            }
        }

        version.setId(id);
        try {
            versionMapper.update(version);
            result.put("success", true);
            result.put("message", "更新成功");
        } catch (DuplicateKeyException e) {
            result.put("success", false);
            result.put("message", "版本号已存在");
        }
        return result;
    }

    public Map<String, Object> delete(Long id) {
        Map<String, Object> result = new HashMap<>();

        Version existing = versionMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "版本不存在");
            return result;
        }

        int usageCount = siteMapper.countByVersionId(id);
        if (usageCount > 0) {
            result.put("success", false);
            result.put("message", "该版本仍有 " + usageCount + " 个局点在使用，无法删除");
            return result;
        }

        versionMapper.deleteById(id);
        result.put("success", true);
        result.put("message", "删除成功");
        return result;
    }

    public Map<String, Object> checkVersionCode(String versionCode) {
        Map<String, Object> result = new HashMap<>();
        Version existing = versionMapper.findByVersionCode(versionCode);
        result.put("exists", existing != null);
        return result;
    }
}
