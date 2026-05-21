package com.swat.service;

import com.swat.mapper.IssueCategoryMapper;
import com.swat.mapper.IssueMapper;
import com.swat.model.Issue;
import com.swat.model.IssueCategory;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class IssueCategoryService {

    private final IssueCategoryMapper mapper;
    private final IssueMapper issueMapper;

    public IssueCategoryService(IssueCategoryMapper mapper, IssueMapper issueMapper) {
        this.mapper = mapper;
        this.issueMapper = issueMapper;
    }

    /** Return full tree with children nested */
    public List<IssueCategory> tree() {
        List<IssueCategory> all = mapper.findAll();
        Map<Long, IssueCategory> map = new LinkedHashMap<>();
        for (IssueCategory c : all) {
            c.setChildren(new ArrayList<>());
            map.put(c.getId(), c);
        }

        List<IssueCategory> roots = new ArrayList<>();
        for (IssueCategory c : all) {
            if (c.getParentId() == null) {
                roots.add(c);
            } else {
                IssueCategory parent = map.get(c.getParentId());
                if (parent != null) {
                    parent.getChildren().add(c);
                }
            }
        }
        return roots;
    }

    public List<IssueCategory> list() {
        return mapper.findAll();
    }

    public IssueCategory getById(Long id) {
        return mapper.findById(id);
    }

    public Map<String, Object> create(IssueCategory cat) {
        Map<String, Object> result = new HashMap<>();
        if (cat.getName() == null || cat.getName().trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "分类名称不能为空");
            return result;
        }
        cat.setName(cat.getName().trim());

        if (cat.getParentId() != null && cat.getParentId() > 0) {
            IssueCategory parent = mapper.findById(cat.getParentId());
            if (parent == null) {
                result.put("success", false);
                result.put("message", "父级分类不存在");
                return result;
            }
            cat.setLevel(parent.getLevel() + 1);
        } else {
            cat.setParentId(null);
            cat.setLevel(1);
        }

        if (cat.getSortOrder() == null) cat.setSortOrder(0);
        if (cat.getColor() == null) cat.setColor("blue");

        mapper.insert(cat);
        result.put("success", true);
        result.put("message", "创建成功");
        result.put("data", cat);
        return result;
    }

    public Map<String, Object> update(Long id, IssueCategory cat) {
        Map<String, Object> result = new HashMap<>();
        IssueCategory existing = mapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "分类不存在");
            return result;
        }
        String oldName = existing.getName();
        String newName = cat.getName() != null ? cat.getName().trim() : null;

        if (newName != null && !newName.isEmpty()) {
            existing.setName(newName);
        }
        if (cat.getSortOrder() != null) existing.setSortOrder(cat.getSortOrder());
        if (cat.getColor() != null) existing.setColor(cat.getColor());
        existing.setId(id);

        mapper.update(existing);

        // Sync issue category fields
        if (newName != null && !newName.isEmpty() && !newName.equals(oldName)) {
            syncIssueCategories(oldName, newName);
        }

        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    private void syncIssueCategories(String oldName, String newName) {
        List<Issue> all = issueMapper.findAll("", "", "", "", "", "", "", 0, 100000);
        for (Issue issue : all) {
            String cat = issue.getCategory();
            if (cat != null && !cat.isEmpty()) {
                String[] parts = cat.split(" > ");
                boolean changed = false;
                for (int i = 0; i < parts.length; i++) {
                    if (parts[i].trim().equals(oldName)) {
                        parts[i] = newName;
                        changed = true;
                    }
                }
                if (changed) {
                    issue.setCategory(String.join(" > ", parts));
                    issueMapper.update(issue);
                }
            }
        }
    }

    public Map<String, Object> delete(Long id) {
        Map<String, Object> result = new HashMap<>();
        IssueCategory existing = mapper.findById(id);
        if (existing == null) {
            result.put("success", false);
            result.put("message", "分类不存在");
            return result;
        }
        int children = mapper.countByParentId(id);
        if (children > 0) {
            result.put("success", false);
            result.put("message", "该分类下有 " + children + " 个子分类，请先删除子分类");
            return result;
        }
        mapper.deleteById(id);
        result.put("success", true);
        result.put("message", "删除成功");
        return result;
    }
}
