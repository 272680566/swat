package com.swat.mapper;

import com.swat.model.Site;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SiteMapper {

    List<Site> findAll(@Param("keyword") String keyword);

    Site findById(@Param("id") Long id);

    Site findByName(@Param("name") String name);

    int insert(Site site);

    int update(Site site);

    int deleteById(@Param("id") Long id);

    int countByVersionId(@Param("versionId") Long versionId);
}
