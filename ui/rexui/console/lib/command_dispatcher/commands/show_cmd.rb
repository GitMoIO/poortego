
module PoortegoCommands
  
  #
  # Show command logic
  #
  def cmd_poortego_show(*args)
    # Default show type is the current selection
    show_type = @poortego_session.session_values["Current Selection Type"]
    show_obj  = @poortego_session.session_values["Current Object"] 
   
    # Argument driven type (optional) 
    if (args.length > 0)
      show_type = args[0]
    end
    
    # Argument driven name (optional)
    if (args.length > 1)
      show_name = args[1]
      case show_type
      when '-h', '-?'       
        cmd_poortego_show_help
        return
      when 'project'
        show_obj = PoortegoProject.select(show_name)
      when 'section'
        show_obj = PoortegoSection.select(@poortego_session.session_values["Current Project"].id, 
                                  show_name)
      when 'transform'
        show_obj = PoortegoTransform.select(show_name)
      when 'entity'
        show_obj = PoortegoEntity.select(@poortego_session.session_values["Current Project"].id, 
                                 @poortego_session.session_values["Current Section"].id, 
                                 show_name)
      when 'link'
        show_obj = PoortegoLink.select(@poortego_session.session_values["Current Project"].id, 
                               @poortego_session.session_values["Current Section"].id, 
                               show_name)
      when 'entity_type'
        show_obj = PoortegoEntityType.select(show_name)
      when 'link_type'
        show_obj = PoortegoLinkType.select(show_name)  
      else
        print_error("Invalid show type (#{show_type}).  Use -h if you need help.")
        return
      end              
    end
    if (args.length > 2)
      print_error("Ambiguous arguments.  Use -h if you need help.")
      return
    end
    
    # Populate table with the object's contents
    tbl = Rex::Ui::Text::Table.new('Indent' => 4,
                                   'Columns' => ["#{show_type} fields",
                                                 'values'   ])
    show_obj.attributes.each do |attr_name, attr_value|
      tbl << [attr_name, attr_value] 
      ## TODO? some of these attributes are an "id" such as a Type id, do the name lookup instead?
    end
    print_status("Showing #{show_type}, id #{show_obj.id} :")
    puts "\n" + tbl.to_s
    
    #
    # Table addendum for certain types
    #
    case show_type
    when 'entity_type'
      display_flag = 0
      tbl_more = Rex::Ui::Text::Table.new('Ident'   => 4,
                                          'Columns' => ['associated types'] )                                      
      type_fields = PoortegoEntityTypeField.list(show_obj.id)
      type_fields.each do |type_field|
        tbl_more << [type_field.field_name]
        display_flag = 1
      end
      if (display_flag == 1)
         puts "\n" + tbl_more.to_s
      end
    when 'link_type'
      display_flag = 0
      tbl_more = Rex::Ui::Text::Table.new('Ident'   => 4,
                                          'Columns' => ['associated types'] )                                    
      type_fields = PoortegoLinkTypeField.list(show_obj.id)
      type_fields.each do |type_field|
        tbl_more << [type_field.field_name]
        display_flag = 1
      end
      if (display_flag == 1)
         puts "\n" + tbl_more.to_s
      end  
    when 'section'        # Show Section Descriptors
       display_flag = 0
       tbl_more = Rex::Ui::Text::Table.new('Indent' => 4,
                                           'Columns' => ['section descriptors',
                                                         'values'   ])
       descriptors = PoortegoSectionDescriptor.list(show_obj.id)
       descriptors.each {|descriptor|
         tbl_more << [descriptor.field_name, descriptor.value]
         display_flag = 1 
       }
       if (display_flag == 1)
         puts "\n" + tbl_more.to_s
       end
    when 'link'   # Show link fields
      display_flag = 0
      tbl_more = Rex::Ui::Text::Table.new('Indent' => 4,
                                           'Columns' => ['link fields',
                                                         'values'   ])
      link_fields = PoortegoLinkField.list(show_obj.id)
      link_fields.each {|link_field|
         tbl_more << [link_field.name, link_field.value]
         display_flag = 1 
      }
      if (display_flag == 1)
        puts "\n" + tbl_more.to_s
      end
    when 'entity'  # Show entity fields
      display_flag = 0
      tbl_more = Rex::Ui::Text::Table.new('Indent' => 4,
                                           'Columns' => ['entity fields',
                                                         'values'   ])
      entity_fields = PoortegoEntityField.list(show_obj.id)
      entity_fields.each {|entity_field|
         tbl_more << [entity_field.name, entity_field.value]
         display_flag = 1 
      }
      if (display_flag == 1)
        puts "\n" + tbl_more.to_s
      end
      
      # Display Links From
      ## TODO
      
      # Display Links To
      ## TODO
      
    end
    
    puts "\n"
    
  end
  
  #
  # Show command help
  #
  def cmd_poortego_show_help(*args)
    print_status("Command    : show")
    print_status("Description: displays the values of a selected thing.")
    print_status("Usage      : 'show [type [name]]'")
    print_status("Details    :")
    print_status("Where type and name are optional. Vaid types: project, section, transform, entity, link, entity_type, link_type.")
    print_status("By default the type and name are the current selection unless specified.")
  end
  
  
end

