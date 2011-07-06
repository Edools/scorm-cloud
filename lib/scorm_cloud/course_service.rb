module ScormCloud
	class CourseService < ScormCloud::Base

		not_implemented :import_course, :import_cours_async, :get_async_import_result,
				:preview, :properties, :exists, :get_assets, :update_assets, :delete_course,
				:get_file_structure, :delete_files, :get_attributes, :update_attributes,
				:get_metadata

		def get_manifest(connection, course_id)
			connection.call_raw("rustici.course.getManifest", :courseid => course_id)
		end

		def get_course_list(connection, options = {})
			xml = connection.call("rustici.course.getCourseList", options)
			xml.elements["/rsp/courselist"].map { |e| ScormCloud::Course.from_xml(e) }
		end

	end
end

