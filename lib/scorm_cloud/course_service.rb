module ScormCloud
  class CourseService < BaseService
    not_implemented :properties, :get_assets, :update_assets,
      :get_file_structure, :delete_files, :get_metadata

    # TODO: Handle Warnings
    def import_course(course_id, file)
      if file.respond_to? :read
        xml = connection.post("rustici.course.importCourse", file, :courseid => course_id)
      else
        xml = connection.call("rustici.course.importCourse", :courseid => course_id, :path => file)
      end

      if xml.elements['//rsp/importresult'] && xml.elements['//rsp/importresult'].attributes["successful"] == "true"
        title = xml.elements['//rsp/importresult/title'].text
        { :title => title, :warnings => [] }
      else
        nil
      end
    end

    def import_course_async(course_id, file)
      if file.respond_to? :read
        xml = connection.post("rustici.course.importCourseAsync", file, :courseid => course_id)
      else
        xml = connection.call("rustici.course.importCourseAsync", :courseid => course_id, :path => file)
      end

      if xml.elements['//rsp/token']
        token = xml.elements['//rsp/token/id'].text
        { :token => token, :warnings => [] }
      else
        nil
      end
    end

    def get_async_import_result(token)
      xml = connection.call("rustici.course.getAsyncImportResult", :token => token)

      result = { :status => xml.elements['//rsp/status'].text }
      
      if result[:status] == 'error'
        result[:message] = xml.elements['//rsp/error'].text 
      elsif result[:status] == 'finished'
        if xml.elements['//rsp/importresults/importresult/title']
          result[:title] = xml.elements['//importresults/importresult/title'].text
        elsif result[:title] = xml.elements['//rsp/importresult/title']
          result[:title] = xml.elements['//rsp/importresult/title'].text
        end
      end

      result
    end

    def exists(course_id)
      connection.call_raw("rustici.course.exists", :courseid => course_id).include?("<result>true</result>")
    end

    def get_attributes(course_id)
      xml = connection.call("rustici.course.getAttributes", :courseid => course_id)
      xml_to_attributes(xml)
    end

    def delete_course(course_id)
      connection.call("rustici.course.deleteCourse", :courseid => course_id)
      true
    end

    def get_manifest(course_id)
      connection.call_raw("rustici.course.getManifest", :courseid => course_id)
    end

    def get_course_list(options = {})
      xml = connection.call("rustici.course.getCourseList", options)
      xml.elements["/rsp/courselist"].map { |e| Course.from_xml(e) }
    end

    def preview(course_id, redirect_url)
      connection.launch_url("rustici.course.preview", :courseid => course_id, :redirecturl => redirect_url)
    end

    def update_attributes(course_id, attributes)
      xml = connection.call("rustici.course.updateAttributes", attributes.merge({:courseid => course_id}))
      xml_to_attributes(xml)
    end
  end
end
