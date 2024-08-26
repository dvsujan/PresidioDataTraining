create procedure syncemployeetables
    @debug int = 0 
as
begin
    insert into employeesync (original_emp_id, name, createdat, updatedat, is_deleted)
    select emp_id, name, createdat, updatedat, is_deleted
    from employee
    where emp_id not in (select original_emp_id from employeesync);
    
    insert into employeesync (original_emp_id, name, createdat, updatedat, is_deleted, is_edited)
    select e.emp_id, e.name, e.createdat, e.updatedat, e.is_deleted, 1
    from employee e
    inner join employeesync rs on e.emp_id = rs.original_emp_id
    where e.updatedat > rs.max_updatedat;

    update employeesync
    set is_deleted = 1, updatedat = e.updatedat
    from employeesync es
    inner join employee e on es.original_emp_id = e.emp_id
    where e.is_deleted = 1 and es.is_deleted = 0;
    
    if @debug = 1
        select * from employeesync;
end;