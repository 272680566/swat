package com.swat.service;

import com.swat.mapper.SiteMapper;
import com.swat.mapper.VersionMapper;
import com.swat.model.Site;
import com.swat.model.Version;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class SiteService {

    private final SiteMapper siteMapper;
    private final VersionMapper versionMapper;

    public SiteService(SiteMapper siteMapper, VersionMapper versionMapper) {
        this.siteMapper = siteMapper;
        this.versionMapper = versionMapper;
    }

    public List<Site> listAll() {
        return siteMapper.findAll("", 10000, 0);
    }

    public Map<String, Object> list(String keyword, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        List<Site> list = siteMapper.findAll(keyword, pageSize, offset);
        int total = siteMapper.countFiltered(keyword);
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        result.put("page", page);
        result.put("pageSize", pageSize);
        return result;
    }

    public Site getById(Long id) {
        return siteMapper.findById(id);
    }

    public Map<String, Object> create(Site site) {
        Map<String, Object> result = new HashMap<>();

        Site existing = siteMapper.findByName(site.getName());
        if (existing != null) {
            result.put("success", false);
            result.put("message", "局点名称已存在");
            return result;
        }

        // Auto-generate site code
        if (site.getCode() == null || site.getCode().trim().isEmpty()) {
            String today = java.time.LocalDate.now().toString().replace("-", "");
            int base = siteMapper.countAll();
            boolean inserted = false;
            for (int retry = 0; retry < 10; retry++) {
                site.setCode(String.format("SITE-%s-%03d", today, base + 1 + retry));
                try {
                    siteMapper.insert(site);
                    inserted = true;
                    break;
                } catch (DuplicateKeyException e) {
                    // Retry with next sequence
                }
            }
            if (!inserted) {
                result.put("success", false);
                result.put("message", "创建失败，请重试");
                return result;
            }
        } else {
            try {
                siteMapper.insert(site);
            } catch (DuplicateKeyException e) {
                result.put("success", false);
                result.put("message", "局点名称或编号已存在");
                return result;
            }
        }

        syncVersionSites(site.getId(), new ArrayList<>(), parseVersionIds(site.getVersionIds()));
        result.put("success", true);
        result.put("message", "创建成功");
        result.put("data", site);
        return result;
    }

    public Map<String, Object> update(Long id, Site site) {
        Map<String, Object> result = new HashMap<>();

        Site existing = siteMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "局点不存在");
            return result;
        }

        List<Long> oldVersionIds = parseVersionIds(existing.getVersionIds());
        List<Long> newVersionIds = parseVersionIds(site.getVersionIds());

        site.setId(id);
        site.setName(null);
        siteMapper.update(site);

        syncVersionSites(id, oldVersionIds, newVersionIds);

        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    public Map<String, Object> delete(Long id) {
        Map<String, Object> result = new HashMap<>();

        Site existing = siteMapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "局点不存在");
            return result;
        }

        List<Long> oldVersionIds = parseVersionIds(existing.getVersionIds());
        siteMapper.deleteById(id);
        syncVersionSites(id, oldVersionIds, new ArrayList<>());

        result.put("success", true);
        result.put("message", "删除成功");
        return result;
    }

    public Map<String, Object> checkName(String name) {
        Map<String, Object> result = new HashMap<>();
        Site existing = siteMapper.findByName(name);
        result.put("exists", existing != null);
        return result;
    }

    private List<Long> parseVersionIds(String raw) {
        if (raw == null || raw.trim().isEmpty()) return new ArrayList<>();
        // Handle JSON array like "[1,2,3]" or "[\"1\",\"2\"]"
        String cleaned = raw.trim().replace("\"", "");
        if (cleaned.startsWith("[")) cleaned = cleaned.substring(1);
        if (cleaned.endsWith("]")) cleaned = cleaned.substring(0, cleaned.length() - 1);
        if (cleaned.trim().isEmpty()) return new ArrayList<>();
        List<Long> ids = new ArrayList<>();
        for (String part : cleaned.split(",")) {
            try {
                ids.add(Long.parseLong(part.trim()));
            } catch (NumberFormatException ignored) {}
        }
        return ids;
    }

    private void syncVersionSites(Long siteId, List<Long> oldVersionIds, List<Long> newVersionIds) {
        Set<Long> toAdd = new HashSet<>(newVersionIds);
        toAdd.removeAll(oldVersionIds);

        Set<Long> toRemove = new HashSet<>(oldVersionIds);
        toRemove.removeAll(newVersionIds);

        for (Long vid : toAdd) {
            addSiteToVersion(vid, siteId);
        }
        for (Long vid : toRemove) {
            removeSiteFromVersion(vid, siteId);
        }
    }

    private void addSiteToVersion(Long versionId, Long siteId) {
        Version ver = versionMapper.findById(versionId);
        if (ver == null) return;
        List<Long> siteIds = parseVersionIds(ver.getSites());
        if (!siteIds.contains(siteId)) {
            siteIds.add(siteId);
            versionMapper.updateSites(versionId, siteIds.toString());
        }
    }

    private void removeSiteFromVersion(Long versionId, Long siteId) {
        Version ver = versionMapper.findById(versionId);
        if (ver == null) return;
        List<Long> siteIds = parseVersionIds(ver.getSites());
        if (siteIds.remove(siteId)) {
            versionMapper.updateSites(versionId, siteIds.toString());
        }
    }
}
