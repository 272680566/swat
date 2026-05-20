package com.swat.mapper;

import com.swat.model.Version;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface VersionMapper {

    List<Version> findAll();

    Version findById(@Param("id") Long id);

    int insert(Version version);

    int update(Version version);

    Version findByVersionCode(@Param("versionCode") String versionCode);

    int deleteById(@Param("id") Long id);

    int updateSites(@Param("id") Long id, @Param("sites") String sites);
}
